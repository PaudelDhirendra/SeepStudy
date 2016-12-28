function cycles=sleep_cycles(hyp)
hyp2=hyp;
figure
ax(1)=subplot(311)
plot(hyp)
ax(2)=subplot(312)
% try to figure how to go from 1 to 2
% 1) N1 is wake
hyp(hyp==1)=0;
hyp(hyp>1 & hyp<5)=1;
plot(hyp)
linkaxes(ax,'x')
% 2) define REM phases: if less than 15 min of NREM/wake set to REM
REMstart=find(hyp==5 & [0;diff(hyp)]>0);
REMend=find(hyp==5 & [diff(hyp); 0]<0);
if hyp(1)==5, REMstart=[1;REMstart]; end
if hyp(end)==5, REMend=[REMend;length(hyp)]; end
gaps=REMstart(2:end)-REMend(1:end-1);
for jj=1:length(gaps)
    s=gaps(jj);
    if s<15*2
        hyp(REMend(jj):REMstart(jj+1))=5;
    end
end
hold on

REMstart=find(hyp==5 & [0;diff(hyp)]>0);
REMend=find(hyp==5 & [diff(hyp); 0]<0);
if hyp(1)==5, REMstart=[1;REMstart]; end
if hyp(end)==5, REMend=[REMend;length(hyp)]; end
plot(REMstart,ones(size(REMstart)),'>g')
plot(REMend,ones(size(REMend)),'<m')
plot(hyp)
% 3) REM must be at least 5 min in cycles 2 and later
REMlength=REMend-REMstart;
norem=find(REMlength<5*2);
% first cycle gets a shorter REM
norem(norem==1)=[];
for jj=1:length(norem)
    hyp(REMstart(norem(jj)):REMend(norem(jj)))=1;
end
plot(hyp)
% 4) wake following REM, at the beginning or at the end
% is wake. Other wake is NREM if less than 15 min
truewake=zeros(size(hyp));
if hyp(1)==0
    k=1;
    while hyp(k)==0
        truewake(k)=1;
        k=k+1;
    end
end
if hyp(end)==0
    k=length(hyp);
    while hyp(k)==0
        truewake(k)=1;
        k=k-1;
    end
end
REMend=find(hyp==5 & [diff(hyp); 0]<0);
for j=1:length(REMend)
    if hyp(REMend(j)+1)==0
        k=REMend(j)+1;
        while (k<=length(hyp) && hyp(k)==0)
            truewake(k)=1;
            k=k+1;
        end
    end
end
% add bouts of wake that are longer than 15 min
wakestart=find(hyp==0 & [0;diff(hyp)]<0);
wakeend=find(hyp==0 & [diff(hyp);0]>0);
if hyp(1)==0
    wakestart=[1;wakestart];
end
if hyp(end)==0
    wakeend=[wakeend;length(hyp)];
end
for jj=1:length(wakestart)
    if wakeend(jj)-wakestart(jj)+1>=15*2
        truewake(wakestart(jj):wakeend(jj))=1;
    end
end
hyp(hyp==0)=1;
hyp(truewake==1)=0;
plot(hyp);
% now define cycles based on hyp and original hypnogram
% cycle = NREM phase of at least 15 minutes followed
% by REM phase of at least 5 minutes or by wake/stage1
% of at least 15 minutes
cycles=zeros(size(hyp));
NREMstart=find(hyp==1 & ([0;diff(hyp)]==1 | [0;diff(hyp)]==-4));
NREMend=find(hyp==1 & ([diff(hyp); 0]==-1 | [diff(hyp);0]==4));
if hyp(1)==1, NREMstart=[1;NEMstart]; end
if hyp(end)==1, NREMend=[NREMend;length(hyp)]; end
plot(NREMstart,ones(size(NREMstart)),'>c')
plot(NREMend,ones(size(NREMend)),'<r')
c=1;
for jj=1:length(NREMstart)
    % check length
    if (NREMend(jj)-NREMstart(jj)+1>=15*2 && numel(find(hyp2(NREMstart(jj):NREMend(jj))))>=15*2)
        %check REM
        if (NREMend(jj)+1<=length(hyp) && hyp(NREMend(jj)+1)==5)% REM at end
            k=1;
            while (NREMend(jj)+k<=length(hyp) && hyp(NREMend(jj)+k)==5)
                k=k+1;
            end
            cycles(NREMstart(jj):NREMend(jj)+k-1)=c;
            c=c+1;
        elseif (NREMend(jj)+1<=length(hyp) && hyp(NREMend(jj)+1)==0)% wake at end
            % need at least 15 minutes
            k=1;
            while (NREMend(jj)+k<=length(hyp) && hyp(NREMend(jj)+k)==0)
                k=k+1;
            end
            if (k>15*2 || jj==length(NREMstart))
                % I normally need 15 min of wake at the end
                % but for last cycle omit this criterion
                cycles(NREMstart(jj):NREMend(jj))=c;
                c=c+1;
            end
        elseif  jj==length(NREMstart)
            cycles(NREMstart(jj):NREMend(jj))=c;
            c=c+1;
        end
    end
end
ax(3)=subplot(313)
plot(cycles)
linkaxes(ax,'x')
end