function status = isLinearSvmRequested(svmFlags)
inds = regexp(svmFlags, '-t[\s]+0', 'once');
status = ~isempty(inds);
end
