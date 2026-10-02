
%% - blocul amplificator
figure;
plot(out.intrare, out.amplificator, 'LineWidth', 2);
grid on;
xlabel('u_a [V]', 'FontSize', 12);
ylabel('u_m [V]', 'FontSize', 12);
title('Caracteristica Statica a Amplificatorului', 'FontSize', 14);

%% bloc Rezervor: debitul de iesire in fct de nivelul h
figure;
plot(out.nivel, out.debit_iesire, 'b-', 'LineWidth', 2);
grid on;
xlabel('Nivel h [cm]', 'FontSize', 12);
ylabel('Debit de iesire qe [cm3/s]', 'FontSize', 12);
title('Caracteristica rezervorului pt C=9, h0=17cm', 'FontSize', 14);

%%  verificare identificare
y_sim = out.real;
t_sim = out.tout;

y_initial = 5.5;

Kp_identificat = 2.4;
Tp_identificat = 202;   

Hf_identificat = tf(Kp_identificat, [Tp_identificat, 1]); 
delta_u = 0.5; 

Ts = 0.1; 
t_model = t_sim(1):Ts:t_sim(end);
u_model = delta_u * ones(size(t_model));

y_model = lsim(Hf_identificat, u_model, t_model);
y_model = y_model + y_initial;

figure;
plot(t_sim, y_sim, 'LineWidth', 1.5);
hold on;
plot(t_model, y_model, 'r--', 'LineWidth', 1.5);
xlabel('Timp');
ylabel('Amplitudine');
grid on;
legend('Date Simulink ', 'Model Hf ');
hold off;

%% pct de functionare
k1 = 0.624; 
k2 = -0.015;
k3 = -0.0006;
k = 0.035;
Pv = 2 * 10.5; 
N_const = 9.45; 
q = 0:1:100; 

Pp = k1 * N_const.^2 + k2 * N_const .* q + k3 * q.^2;

Pc = Pv + k * q.^2; 

figure;
plot(q, Pp, 'r-', 'LineWidth', 2, 'DisplayName', 'Caracteristica Pompei (P_p)');
hold on;
plot(q, Pc, 'g-', 'LineWidth', 2, 'DisplayName', 'Caracteristica Instalatiei (P_c)');


q0 = 29.2; 
P0 = Pv + k * q0^2; 
plot(q0, P0, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'DisplayName', 'Punctul de Functionare (q_0, P_0)');

grid on;
xlabel('Debit q [cmc/s]', 'FontSize', 12);
ylabel('Presiune P [cmH2O]', 'FontSize', 12);
title('Determinarea Punctului de Functionare al Pompei (Simulare Fig 2.4)', 'FontSize', 14);
legend('show', 'Location', 'NorthEast');
xlim([0 70]);
ylim([0 100]);
hold off;


