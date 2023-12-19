function symbol = getUniqueLineType(index)
line_type={'-','--',':','-.'};
index=mod(index,4);
if index==0
    index=4;
end
symbol=line_type{index};
end