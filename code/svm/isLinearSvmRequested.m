function status = isLinearSvmRequested(svmFlags)
% Author: saurabh.me@gmail.com (Saurabh Singh).
inds = regexp(svmFlags, '-t[\s]+0', 'once');
status = ~isempty(inds);
end
