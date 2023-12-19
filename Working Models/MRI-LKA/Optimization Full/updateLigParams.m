function []=updateLigParams(DV)
% DV is nx1 or 1xn design vector passed from initial optimization routine
ALS_EREF=DV(1);
ALS_K2=DV(2);

ACLpl_EREF=DV(3);
ACLpl_K2=DV(4);

ACLam_EREF=DV(5);
ACLam_K2=DV(6);

LCL_EREF=DV(7);
LCL_K2=DV(8);

MCLA_EREF=DV(9);
MCLM_EREF=DV(10);
MCLP_EREF=DV(11);
MCL_K2=DV(12);

dMCL_EREF=DV(13);
dMCL_K2=DV(14);

POL_EREF=DV(15);
POL_K2=DV(16);

PCAPL_EREF=DV(17);
PCAPL_K2=DV(18);

PCAPM_EREF=DV(19);
PCAPM_K2=DV(20);

PCLal_EREF=DV(21);
PCLal_K2=DV(22);

PCLpm_EREF=DV(23);
PCLpm_K2=DV(24);

PFL_EREF=DV(25);
PFL_K2=DV(26);

%% Make copy of file, inputing new design variables, replace when complete

readfilename = ['LIG-PARAMETERS-S192803L-FINAL2.inp'];
writefilename = ['LIG-PARAMETERS-S192803L-FINAL2_new.inp'];
readfile = fopen(readfilename);
writefile = fopen(writefilename,'w');

tline = fgetl(readfile);
while ischar(tline)
    if (~isempty(strfind(tline, 'ALS_EREF=')))
        % Write new parameter
        s1 = ['ALS_EREF=' num2str(ALS_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'ALS_K2=')))
        s1 = ['ALS_K2=' num2str(ALS_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'ACLpl_EREF=')))
        s1 = ['ACLpl_EREF=' num2str(ACLpl_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'ACLpl_K2=')))
        s1 = ['ACLpl_K2=' num2str(ACLpl_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'ACLam_EREF=')))
        s1 = ['ACLam_EREF=' num2str(ACLam_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'ACLam_K2=')))
        s1 = ['ACLam_K2=' num2str(ACLam_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'LCL_EREF=')))
        s1 = ['LCL_EREF=' num2str(LCL_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'LCL_K2=')))
        s1 = ['LCL_K2=' num2str(LCL_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'MCLA_EREF=')))
        s1 = ['MCLA_EREF=' num2str(MCLA_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'MCLM_EREF=')))
        s1 = ['MCLM_EREF=' num2str(MCLM_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'MCLP_EREF=')))
        s1 = ['MCLP_EREF=' num2str(MCLP_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'MCL_K2=')) && isempty(strfind(tline, 'dMCL_K2='))) % Extra case to prevent dMCL / MCL issues
        s1 = ['MCL_K2=' num2str(MCL_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'dMCL_EREF=')))
        s1 = ['dMCL_EREF=' num2str(dMCL_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'dMCL_K2=')))
        s1 = ['dMCL_K2=' num2str(dMCL_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'POL_EREF=')))
        s1 = ['POL_EREF=' num2str(POL_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'POL_K2=')))
        s1 = ['POL_K2=' num2str(POL_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'PCAPL_EREF=')))
        s1 = ['PCAPL_EREF=' num2str(PCAPL_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'PCAPL_K2=')))
        s1 = ['PCAPL_K2=' num2str(PCAPL_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'PCAPM_EREF=')))
        s1 = ['PCAPM_EREF=' num2str(PCAPM_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'PCAPM_K2=')))
        s1 = ['PCAPM_K2=' num2str(PCAPM_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'PCLal_EREF=')))
        s1 = ['PCLal_EREF=' num2str(PCLal_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'PCLal_K2=')))
        s1 = ['PCLal_K2=' num2str(PCLal_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'PCLpm_EREF=')))
        s1 = ['PCLpm_EREF=' num2str(PCLpm_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'PCLpm_K2=')))
        s1 = ['PCLpm_K2=' num2str(PCLpm_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'PFL_EREF=')))
        s1 = ['PFL_EREF=' num2str(PFL_EREF,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    elseif(~isempty(strfind(tline, 'PFL_K2=')))
        s1 = ['PFL_K2=' num2str(PFL_K2,'%.12f')];
        fprintf(writefile,'%s\n',s1);
    else
        fprintf(writefile,'%s\n',tline);
    end
    tline = fgetl(readfile);
end
fclose(writefile);
fclose(readfile);

%Delete Previous and Rename new file
delete(readfilename);
movefile(writefilename,readfilename);

end