function numbers = getRandForPdf(dist, n)
cumul = cumsum(dist);
steps = 0:1/(length(dist)-1):1;
cumulInv = zeros(1, length(cumul));
cumulInd = 1;
for i = 1 : length(steps)
  if steps(i) < cumul(cumulInd)
    cumulInv(i) = cumulInd;
  else
    while cumulInd < length(steps) && steps(i) > cumul(cumulInd) + eps
      cumulInd = cumulInd + 1;
    end
    cumulInv(i) = cumulInd;
  end
end
numbers = round(rand(1, n) * (length(dist) - 1)) + 1;
numbers = cumulInv(numbers);
end