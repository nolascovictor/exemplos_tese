% It's provide a rigorous verification of numerical solution of IVP or BVP
% u'(t) - f(t,u(t)) = [0,...,0], u(t0) = x0 (u(L) = x1) where f: R^(n+1) \to R^n, f=f(t,u(t)) is
% C2 and u: [t0, L] \to Rn, u = u(t) = (u1(t),...,un(t)). That is, if there
% exists a true solution near to numerical solution obtained. For that,
% the first part, "compute_solution", compute a numerical solution "b" for the system 
% u'(t)- f((L - t0)t + t0, u(t) + x0)(L - t0) = [0,...,0] 
% subject to initial condition u(0) = [0,...,0] (u(1) = x1-x0) by fsolver and ode45. 
% Note that, "b" has the coefficients of numerical 
% solution "w" in (H^{1,0}_B)^n. After that, using
% Theorem 2 of cited paper above, "verify_solution"
% verifies if there exists a true solution of u'(t)- f((L - t0)t + t0, u(t) + x0)(L - t0) = [0,...,0] 
% u(0) = [0,...,0] (u(1) = x1-x0), in closed ball B[w,R] 
% of (H^{1,0}_B)^n. The "t_star \in [0,R]" provides existence radius and "t_2star"
% provides uniqueness radius in (H^{1,0}_B)^n.
% 
% Input: f, d_uf, m, n, R, parameters (if necessary), intvSol = [t0, L], initCond and finalCond (for BVP).
% Output: Message about verification state and plot of numerical solution. If the message is 'Proof was successful!' then 
% it shows eta, nu, K, t_star, t_2star, elapsed time in seconds.

% True solution u*(t) = [c2*sin(t) + c1*cos(t)+t, -c1*sin(t) + c2*cos(t)+1], u*(t0) = [x0, y0].
% du*(t) = [c2*cos(t) - c1*sin(t)+1, -c1*cos(t) - c2*sin(t)]

set(0, 'DefaultAxesFontSize', 18)
set(0, 'DefaultAxesFontWeight', 'bold')
tic
clear; clc; close all; close all force;
 
%% Define the equation and its derivative
f = @(t,x) [x(2), t-x(1)];
d_uf = @(t,x) [0, 1; -1, 0]; 

%% Define initial guess and parameters
m = 32; % Projection dimension
n = 2; % system size
R = 1; % radius of  Newton-Kantorovik verification
intvSol = [-1,2]; % interval [t0, L], L > t0, of solution domain. 
initCond = {10,3}; % u(t0) = initCond. 
finalCond = {}; % For IVP finalCond={}. For BVP finalCond = {u1(L), u2(L),...,un(L)}, put [] on emty spaces

%% Compute numerical solution to u'(t) = f((L - t0)t + t0, u + x0)(L - t0), u(0) = 0
[b, t0, L, x0]   = compute_solution(f, d_uf, m, n, intvSol, initCond, finalCond);
% b is a matrix whose elements are the coefficients of numerical solution w in H^{1,0}_B(I)^n
% [t0,L], L > t0, solution domain
% x0 = initCond

%% Verify the numerical solution
[eta, nu, K, t_star, t_2star] = verify_solution(b, f, t0, L, x0, d_uf, R);
% eta is the norm of F(w)= w'(t) - f(t, w(t)) in L2(I)^n, where w is numerical solution
% nu is bijectivity modulus
% K is a D2_uf bound
% t_star \in [0,R] provides existence radius in (H^{1,0}_B)^n
% t_2star provides uniqueness radius in (H^{1,0}_B)^n.
ElapsedTime = toc;
disp(['Elapsed Time in seconds = ', num2str(ElapsedTime)])


%% Plot the solution
w = @(x) compute_u(b, (x-t0)/(L-t0)) + x0;
x = t0 + ((0:10)/10).*(L - t0);
A = zeros(size(x,2), n);
% true solution for u'(t) = [u(2), t-u(1)], t\in [-1,2], u(-1) = [10, 3]
c1 = 11*cos(1) + 2*sin(1);
c2 = -11*sin(1) + 2*cos(1);
u = @(t) [c2*sin(t) + c1*cos(t) + t, -c1*sin(t) + c2*cos(t) + 1]; 
B = reshape(u(x), [size(x,2),n]);
for i=1:size(x,2) 
    A(i,:) = w(x(i));
end 
% 2D - Plot I
figure(1);
p = plot(x, B(:,1), 'k', x, A(:,1), '--gs'); xlim([t0,L]);
p(1).LineWidth = 3;
p(2).LineWidth = 2;
%title('2D Plot of the Numerical Solution and True Solution')
legend({'Solu��o Te�rica u^*', 'Solu��o num�rica w'},'Location','northwest')
xlabel('Tempo t')
ylabel('Eixo X')
pos1 = get(gcf,'Position'); % get position of Figure(1) 
set(gcf,'Position', pos1 - [pos1(3)/2,0,0,0]) % Shift position of Figure(1) 
% 2D - Plot II
figure(2);
q = plot(x, B(:,2), 'k', x, A(:,2), '--gs'); xlim([t0,L]);
q(1).LineWidth = 3;
q(2).LineWidth = 2;
%title('2D Plot of the Numerical Solution and True Solution')
legend({'Solu��o Te�rica u^*', 'Solu��o num�rica w'},'Location','northwest')
xlabel('Tempo t')
ylabel('Eixo Y')
set(gcf,'Position', get(gcf,'Position') + [0,0,0,0]); % When Figure(2) is not the same size as Figure(1)
pos2 = get(gcf,'Position');  % get position of Figure(2) 
set(gcf,'Position', pos2 + [pos1(3)/2,0,0,0]) % Shift position of Figure(2) 
% 3D - Plot 
figure(3);
p1 = plot3(B(:,1),B(:,2), x, 'k');
p1.LineWidth = 3;
hold on
p2 = plot3(A(:,1),A(:,2), x,'--gs');
p2.LineWidth = 2;
xlabel('Eixo X')
ylabel('Eixo Y')
zlabel('Tempo t')
%title('3D Plot of the Numerical Solution and True Solution')
grid on
axis square
legend({'Solu��o Te�rica u^*', 'Solu��o num�rica w'},'Location','northwest')