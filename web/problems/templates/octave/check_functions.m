function b = check_has_solution(part)
  b = length(strtrim(part.solution))>0;
end

function check_initialize(parts)
  check.parts = parts;
  for i =1:length(parts)
    check.parts{i}.valid = 1;
    check.parts{i}.feedback = cell(0);
    check.parts{i}.secret = cell(0);
  end
  check.part_counter = 0;
end

function r = check_part()
  check.part_counter = check.part_counter + 1;
  check.current_part = check.parts{check.part_counter};
  r = check_has_solution(check.current_part);
end

function check_error(message)
  check.parts{check.part_counter}.valid = 0;
  check_feedback(message);
end

function check_feedback(message)
	% append feedbact
  check.parts{check.part_counter}.feedback(end+1) = {message};
end

function S = leadsubmatrix(A,top)
    if nargin<2, top = 3; end
    n = size(A); n1 = min(top,n(1)); n2 = min(top,n(2));
    S = mat2str(A(1:n1,1:n2));
    if n(1)>top || n(2)>top
        S = sprintf('%s (glavna podmatrika %dx%d)',S,n1,n2);
    end
end

function res = check_equal(koda, rezultat, tol)
    % rezultat ne sme vsebovati Inf ali NaN, da bo primerjava mozna
    res = 0;
    if nargin<3, tol = 1e-6; end
    % pogledamo, ce je rezultat polje, to uporabimo kadar funkcija vrne vec izhodnih podatkov
    if iscell(rezultat)
        nout = length(rezultat);
    else
        nout = 1;
        % shranimo rezultat v polje velikosti ena, da bo primerjava potekala na isti nacin
        tmp = rezultat;
        rezultat = cell(1);
        rezultat{1} = tmp;
    end
    % iz rezultata poberemo toliko izhodov, kot jih potrebujemo za preverjanje
    odg = cell(1,nout);
    [odg{:}] = eval(koda);
    % preverimo vsako polje odgovora ce se ujema z danim rezultatom
    for i = 1:nout
        if nout>1
            izhodstr = sprintf(' v %d. izhodu',i);
        else
            izhodstr = '';
        end 
        if length(size(odg{i})) ~= length(size(rezultat{i}))
            check_error(sprintf('Izraz %s%s vrne tenzor reda %d namesto reda %d', koda,izhodstr,length(size(odg(i))),length(size(rezultat(i)))));
        elseif any(size(odg{i}) ~= size(rezultat{i}))
           check_error(sprintf('Izraz %s%s vrne matriko dimenzije %s namesto %s', koda,izhodstr,mat2str(size(odg{i})),mat2str(size(rezultat{i}))));
        elseif (norm(odg{i} - rezultat{i},'fro') > tol) || any(isnan(odg{i}(:)))
            check_error(sprintf('Izraz %s%s vrne %s namesto %s', koda,izhodstr,leadsubmatrix(odg{i}),leadsubmatrix(rezultat{i})));
        res = 1;
        end
    end
end

function check_secret(x,hint)
  if nargin<2, hint=''; end  
  check.parts{check.part_counter}.secret{end+1} = x;
end

function res = check_substring(koda, podniz)
  res = 0;
  if ~isempty(strfind(koda,podniz))
    check_error(['Resitev ne sme vsebovati niza ',podniz]);
    res = 1;
  end
end

function res = check_regexp(source_code, pattern)
% Checks that given source code does not contain given pattern.
  res = 0;
  if ~isempty(regexp(source_code, pattern))
    check_error(['Resitev ne sme vsebovati vzorca ', pattern]);
    res = 1;
  end
end

function check_summarize()
  for i=1:check.part_counter
    if not(check_has_solution(check.parts{i}))
      fprintf('%d. podnaloga je brez resitve.\n', i);
    elseif not(check.parts{i}.valid)
      fprintf('%d. podnaloga nima veljavne resitve.\n',i);
    else
      fprintf('%d. podnaloga ima veljavno resitev.\n', i);
    end
    for j = 1:length(check.parts{i}.feedback)
      fprintf('  - %d ',j);
      disp(char(check.parts{i}.feedback(j)));
    end
  end
end
