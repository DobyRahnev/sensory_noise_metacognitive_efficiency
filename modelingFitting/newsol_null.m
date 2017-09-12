function params = newsol_null(params)

% Choose which parameter to alter (only parameters 2-5)
index = 1 + randi(4);

% Figure out by how much to alter that parameter
change = randn/10;
params(index) = params(index) + change;

% If the parameters is 2, 4, or 5, make sure that it's not smaller than 0
if any(index==[2,4,5]) && params(index) < 0
    params(index) = params(index) - 2*change;
end
