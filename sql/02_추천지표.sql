-- 추천 지표 표 "추천_지표" 만들기
-- 대상: 최근 12개 분기(2023년 3분기 ~ 2026년 2분기)에 커피-음료 매출이 모두 공개된 상권
-- 기간: 2년 전 4개 분기(20233~20242), 1년 전 4개 분기(20243~20252), 최근 4개 분기(20253~20262)
-- 금액·건수는 그 분기의 월평균이다. 계절 효과를 피하려고 4개 분기 합계끼리, 같은 분기끼리 비교한다.

DROP TABLE IF EXISTS "추천_지표";

CREATE TABLE "추천_지표" AS
WITH 분기 AS (
    SELECT
        m."상권_코드",
        m."기준_년분기_코드" AS 분기,
        m."당월_매출_금액"::numeric AS 금액,
        m."당월_매출_건수"::numeric AS 건수,
        p."전체_점포_수"::numeric AS 점포,
        CASE
            WHEN m."기준_년분기_코드" <= '20242' THEN '2년전'
            WHEN m."기준_년분기_코드" <= '20252' THEN '1년전'
            ELSE '최근'
        END AS 구간
    FROM "커피_매출" m
    JOIN "커피_점포" p USING ("기준_년분기_코드", "상권_코드")
    WHERE m."기준_년분기_코드" BETWEEN '20233' AND '20262'
),
대상 AS (
    SELECT "상권_코드"
    FROM 분기
    GROUP BY "상권_코드"
    HAVING COUNT(*) = 12
),
대상_분기 AS (
    -- 12개 분기가 빈틈없이 이어지므로 LAG(…, 4)가 1년 전 같은 분기다
    SELECT 분기.*,
        LAG(건수) OVER (PARTITION BY "상권_코드" ORDER BY 분기) AS 앞_건수,
        LAG(금액) OVER (PARTITION BY "상권_코드" ORDER BY 분기) AS 앞_금액,
        LAG(건수, 4) OVER (PARTITION BY "상권_코드" ORDER BY 분기) AS 전년_건수
    FROM 분기
    JOIN 대상 USING ("상권_코드")
),
구간_합계 AS (
    SELECT
        "상권_코드",
        -- CASE WHEN에 ELSE가 없으면 조건에 맞지 않는 행은 NULL이 되고, SUM·AVG·COUNT는 NULL을 건너뛴다.
        -- 그래서 그 구간의 행만 계산된다. AVG에 ELSE 0을 붙이면 0이 평균에 들어가므로 붙이지 않는다.
        SUM(CASE WHEN 구간 = '2년전' THEN 건수 END) AS 건수_2년전,
        SUM(CASE WHEN 구간 = '최근' THEN 건수 END) AS 건수_최근,
        SUM(CASE WHEN 구간 = '2년전' THEN 금액 END) AS 금액_2년전,
        SUM(CASE WHEN 구간 = '최근' THEN 금액 END) AS 금액_최근,
        AVG(CASE WHEN 구간 = '2년전' THEN 점포 END) AS 점포_2년전,
        AVG(CASE WHEN 구간 = '최근' THEN 점포 END) AS 점포_최근,
        -- 데이터 단절: 한 분기에 손님이 2배 넘게 뛰거나 절반 아래로 떨어진 분기가 하나라도 있음
        MAX(CASE WHEN 건수 > 앞_건수 * 2 OR 건수 < 앞_건수 * 0.5 THEN 1 ELSE 0 END) = 1 AS 단절,
        -- 같은 매출 금액이 연속 분기에 반복된 적이 있음
        MAX(CASE WHEN 금액 = 앞_금액 THEN 1 ELSE 0 END) = 1 AS 같은_매출_반복,
        -- 최근 4개 분기 중 1년 전 같은 분기보다 손님이 많은 분기 수
        COUNT(CASE WHEN 구간 = '최근' AND 건수 > 전년_건수 THEN 1 END) AS 전년동기_상승_분기_수
    FROM 대상_분기
    GROUP BY "상권_코드"
),
지표 AS (
    SELECT
        g."상권_코드",
        y."상권_코드_명",
        y."상권_구분_코드_명",
        y."자치구_코드_명",
        y."엑스좌표_값",
        y."와이좌표_값",
        ROUND(g.점포_2년전, 2) AS 점포_2년전,
        ROUND(g.점포_최근, 2) AS 점포_최근,
        ROUND((g.건수_최근 / g.건수_2년전 - 1) * 100, 2) AS 손님_2년_증가율,
        ROUND((g.점포_최근 / g.점포_2년전 - 1) * 100, 2) AS 점포_2년_증가율,
        ROUND(((g.건수_최근 / g.점포_최근) / (g.건수_2년전 / g.점포_2년전) - 1) * 100, 2) AS 점포당_손님_2년_증가율,
        ROUND(((g.금액_최근 / g.건수_최근) / (g.금액_2년전 / g.건수_2년전) - 1) * 100, 2) AS 건당_금액_2년_변화율,
        g.전년동기_상승_분기_수,
        ROUND(g.건수_최근 / 4 / g.점포_최근) AS 점포당_월_손님,
        ROUND(g.금액_최근 / 4 / g.점포_최근) AS 점포당_월_매출,
        g.단절,
        g.같은_매출_반복
    FROM 구간_합계 g
    JOIN "영역" y USING ("상권_코드")
)
SELECT
    지표.*,
    -- 같은 상권 유형 안에서의 위치(0~100, 클수록 높음)
    ROUND((PERCENT_RANK() OVER (PARTITION BY "상권_구분_코드_명" ORDER BY 점포당_월_손님) * 100)::numeric, 1) AS 점포당_월_손님_유형내_백분위,
    ROUND((PERCENT_RANK() OVER (PARTITION BY "상권_구분_코드_명" ORDER BY 점포당_월_매출) * 100)::numeric, 1) AS 점포당_월_매출_유형내_백분위
FROM 지표;

ALTER TABLE "추천_지표" ADD PRIMARY KEY ("상권_코드");
