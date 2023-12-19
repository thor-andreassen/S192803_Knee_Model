function result=testCharPresentInChar(in_char,test_char,caseSensitive)
    if nargin<=2
       if ~isempty(strfind(lower(char(in_char)),lower(test_char)))
           result=1;
       elseif strcmpi(char(in_char),test_char)
           result=1;
       else
           result=0;
       end
           
    else
        if caseSensitive==1
            if ~isempty(strfind(lower(char(in_char)),lower(test_char)))
                result=1;
            elseif strcmpi(char(in_char),test_char)
                result=1;
            else
                result=0;
            end
        else
            if ~isempty(strfind(char(in_char),test_char))
                result=1;
            elseif strcmp(char(in_char),test_char)
                result=1;
            else
                result=0;
            end
        end
    end

end