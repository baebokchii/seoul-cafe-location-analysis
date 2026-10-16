-- 영역: 상권 하나에 행 하나
ALTER TABLE "영역" ADD PRIMARY KEY ("상권_코드");

-- 매출·점포: 분기마다 상권 하나에 행 하나(커피-음료만 적재했으므로 업종 코드는 키에 넣지 않음)
ALTER TABLE "커피_매출" ADD PRIMARY KEY ("기준_년분기_코드", "상권_코드");
ALTER TABLE "커피_점포" ADD PRIMARY KEY ("기준_년분기_코드", "상권_코드");
