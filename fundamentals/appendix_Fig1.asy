import graph;
size(4inches, 3.5inches);


real p_eta1(real T) { return (2.0*log(T) + 0.4);}
real p_eta2(real T) { return (2.0*log(T));}

xaxis("$T$", 0, 5, Arrow);
yaxis("$p$", 0, 5, Arrow);

draw("$\eta_1$", graph(p_eta1, 0.85, 4.5), align=N);
draw("$\eta_2$", graph(p_eta2, 1.1, 4.5));

real p1_x=3.5;
real p2_x=3.3;
real pR_y=1.3;

dot("A$(T_1,p_1)$", (p1_x, p_eta1(p1_x)), align=NW, Fill);
dot("B$(T_2,p_2)$", (p2_x, p_eta2(p2_x)), align=SE, Fill);

dot("A$^\prime(\theta_1,p_R)$", (exp(0.5*pR_y-0.2), pR_y), align=2SW, Fill);
dot("B$^\prime(\theta_2,p_R)$", (exp(0.5*pR_y), pR_y), align=2SE, Fill);


yequals(Label("$p_R$", -0.03, up), pR_y, extend=true, black+dashed);
