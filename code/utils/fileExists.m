function res = fileExists(filename)
%function res = fileexists(filename)
%
% Check if file filename exists, and return 0 or 1
% NOTE: much faster than exist(filename,'file')
fid = fopen(filename,'r');
if fid == -1
  res = false;
else
  fclose(fid);
  res = true;
end
end
