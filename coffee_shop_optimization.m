clear; clc; close all;

%% ========================================================================
%  SECTION 1 — MENU-LEVEL DATA  
% =========================================================================

% Menu item names
menu_names = {
    'Single Espresso';          %1
    'Double Espresso';          %2
    'Cafe Latte';               %3
    'Cappuccino';               %4
    'Cafe Mocha';               %5
    'Espresso Tonic';           %6
    'Milk Brew Coffee';         %7
    'Honduras Pour Over';       %8
    'Ethiopia Pour Over';       %9
    'Costa Rica Pour Over';     %10
    'Rwanda Pour Over';         %11
    'Indonesia Pour Over';      %12
    'Saeakari Green Tea';       %13
    'Tsuyuhikari Green Tea';    %14
    'Marubi Roasted Tea';       %15
    'Marushige Genmai Tea';     %16
    'Matcha Latte';             %17
    'Hojicha Latte';            %18
    'Bag of Beans';             %19
};
n_menu = length(menu_names);

% Selling prices (¥ per item)
sell_price = [550; 700; 700; 700; 720; 750; 720; 780; 760; 740;
    760; 650; 680; 620; 660; 580; 750; 700; 1400];

% Ingredient COGS per drink (¥)
%  Only coffee/tea + milk components modelled (dominant variable costs).
cogs = [28.188; 56.376; 133.04; 117.5; 133.04; 56.376; 170.744; 63.504;
    65.772; 54.789; 51.03; 38.85; 60; 54; 75; 30; 140.664; 124.664; 313.2];

% Observed weekly volumes (proxy sales data, 7-day period)
weekly_vol = [0; 0; 9; 3; 1; 0; 4; 2; 8; 8; 10; 16; 2; 3; 8; 2; 4; 10; 0];

% Total CO2 per drink (kg CO2) (dominant variable costs)
co2_per_drink = [0.05691; 0.11382; 0.11576; 0.11537; 0.11576;
    0.11382; 0.22286; 0.16088; 0.13279; 0.16088; 0.15194; 0.07022;
    0.00005; 0.00005; 0.00005; 0.00005; 0.00215; 0.00209; 0.63232];

% Gross profit per drink (cross-checked with sheet)
profit_per_drink = sell_price - cogs;   % ¥ per drink

% Weekly totals at observed volumes (baseline) (cross-checked)
baseline_revenue = sum(sell_price .* weekly_vol);
baseline_cogs    = sum(cogs       .* weekly_vol);
baseline_profit  = sum(profit_per_drink .* weekly_vol);
baseline_co2     = sum(co2_per_drink    .* weekly_vol);

fprintf('=== BASELINE (observed mix) ===\n');
fprintf('  Weekly Revenue : ¥%10.0f\n', baseline_revenue);
fprintf('  Weekly COGS    : ¥%10.0f\n', baseline_cogs);
fprintf('  Weekly Profit  : ¥%10.0f\n', baseline_profit);
fprintf('  Weekly CO2     :  %10.4f  kg\n\n', baseline_co2);


%% ========================================================================
%  SECTION 2 — PROCUREMENT DATA 
% =========================================================================

ingr_names = {
    'Bread';             %  1
    'Unsalted Butter';   %  2
    'Ethiopian Coffee';  %  3
    'Hakodate Milk';     %  4
    'Tea hojicha roast'; %  5
    'Tea matcha medium'; %  6
    'Tea high roasting'; %  7
    'Rwanda Coffee';     %  8
    'Tea matcha';        %  9
    'Milk';              % 10
    'Cream';             % 11
    'Medium matcha';     % 12
    'Hojicha';           % 13
    'Granulated Sugar';  % 14
    'Tea maruhi';        % 15
    'Tea hojicha sand';  % 16
    '8oz Cups';          % 17
    'Tea sencha saemei'; % 18
    'Tea deep steamed';  % 19
    'Lids';              % 20
    'Vanilla Bean';      % 21
    'Cheese Powder';     % 22
    'Egg Yolks';         % 23
    'Tea okuharuka';     % 24
    'Tea genmaicha';     % 25
    'Tea tsuyuhikari';   % 26
    'Maple Syrup';       % 27
    'Brown Sugar';       % 28
    'Chocolate Sauce';   % 29
    'Drip bags';         % 30
    'Frozen Egg Whites'; % 31
    'Indonesian Coffee'; % 32
    'Kenyan Coffee';     % 33
    'Honduras Coffee';   % 34
};
n_ingr = length(ingr_names);

R = zeros(34, 19);

% Ethiopian Coffee (ingredient 3)
R(3,  1) = 9;    % Single Espresso
R(3,  2) = 18;   % Double Espresso
R(3,  3) = 18;   % Cafe Latte
R(3,  4) = 18;   % Cappuccino
R(3,  5) = 18;   % Cafe Mocha
R(3,  6) = 18;   % Espresso Tonic
R(3,  7) = 35;   % Milk Brew Coffee
R(3,  9) = 21;   % Ethiopia Pour Over
R(3, 19) = 100;  % Bag of Beans

% Honduras Coffee (ingredient 34)
R(34,  8) = 21;  % Honduras Pour Over

% Rwanda Coffee (ingredient 8)
R(8,  11) = 21;  % Rwanda Pour Over

% Indonesian Coffee (ingredient 32)
R(32, 12) = 21;  % Indonesia Pour Over

% Milk/regular (ingredient 10) — confirmed 296ml=regular milk
R(10,  3) = 296;  % Cafe Latte
R(10,  4) = 236;  % Cappuccino
R(10,  5) = 296;  % Cafe Mocha
R(10,  7) = 236;  % Milk Brew Coffee
R(10, 17) = 296;  % Matcha Latte
R(10, 18) = 296;  % Hojicha Latte

% Tea (matcha) (ingredient 9)
R(9,  17) = 4;   % Matcha Latte

% Hojicha (ingredient 13)
R(13, 18) = 3;   % Hojicha Latte

% Tea (maruhi) (ingredient 15)
R(15, 15) = 3;   % Marubi Roasted Tea

% Tea (genmaicha) (ingredient 25)
R(25, 16) = 3;   % Marushige Genmai Tea

% Tea (tsuyuhikari) (ingredient 26)
R(26, 14) = 3;   % Tsuyuhikari Green Tea

% Tea (sencha saemei) (ingredient 18)
R(18, 13) = 3;   % Saeakari Green Teasom

%% ========================================================================
%  SECTION 3 — MENU-LEVEL OPTIMIZATION
% =========================================================================

% Volume bounds
v_min = 0.50 * weekly_vol;   % demand floor
v_max = 1.50 * weekly_vol;   % capacity ceiling

% Category membership
%  Coffee: items 1-12 and 19 (espresso-based, pour overs, retail bags)
%  Tea: items 13-18
idx_coffee = [1:12, 19];
idx_tea    = 13:18;

% Coefficient vectors
f_profit = profit_per_drink;    % maximize: f_profit' * v
f_co2    = co2_per_drink;       % minimize: f_co2' * v

%% ── Pass 1: Maximize profit (unconstrained on CO2) ──────────────────────
cvx_begin quiet
    variable v1(n_menu)
    maximize( f_profit' * v1 )
    subject to
        v1 >= v_min;
        v1 <= v_max;
        % Coffee/tea share floors
        sum(v1(idx_coffee)) >= 0.50 * sum(v1);
        sum(v1(idx_tea))    >= 0.15 * sum(v1);
cvx_end

profit_max  = f_profit' * v1;
co2_at_pmax = f_co2'    * v1;
fprintf('=== PASS 1: Max Profit ===\n');
fprintf('  Max weekly profit : ¥%.0f\n', profit_max);
fprintf('  CO2 at max profit  : %.4f kg\n\n', co2_at_pmax);

%% ── Pass 2: Minimize CO2 (unconstrained on profit) ──────────────────────
cvx_begin quiet
    variable v2(n_menu)
    minimize( f_co2' * v2 )
    subject to
        v2 >= v_min;
        v2 <= v_max;
        sum(v2(idx_coffee)) >= 0.50 * sum(v2);
        sum(v2(idx_tea))    >= 0.15 * sum(v2);
cvx_end

co2_min          = f_co2'    * v2;
profit_at_co2min = f_profit' * v2;
fprintf('=== PASS 2: Min CO2 ===\n');
fprintf('  Min weekly CO2    : %.4f kg\n', co2_min);
fprintf('  Profit at min CO2  : ¥%.0f\n\n', profit_at_co2min);


%% ========================================================================
%  SECTION 4 — PARETO FRONTIER 
% =========================================================================

N_pts = 40;   % number of Pareto points
eps_grid = linspace(co2_min, co2_at_pmax, N_pts);

pareto_profit = zeros(N_pts, 1);
pareto_co2    = zeros(N_pts, 1);
pareto_v      = zeros(n_menu, N_pts);

for k = 1:N_pts
    eps_k = eps_grid(k);
    cvx_begin quiet
        variable vk(n_menu)
        maximize( f_profit' * vk )
        subject to
            vk >= v_min;
            vk <= v_max;
            f_co2' * vk <= eps_k;
            sum(vk(idx_coffee)) >= 0.50 * sum(vk);
            sum(vk(idx_tea))    >= 0.15 * sum(vk);
    cvx_end

    if strcmp(cvx_status, 'Solved') || strcmp(cvx_status, ...
            'Inaccurate/Solved')
        pareto_profit(k) = f_profit' * vk;
        pareto_co2(k)    = f_co2'    * vk;
        pareto_v(:,k)    = vk;
    else
        pareto_profit(k) = NaN;
        pareto_co2(k)    = NaN;
    end
end

% Remove infeasible points
valid = ~isnan(pareto_profit);
pareto_profit = pareto_profit(valid);
pareto_co2    = pareto_co2(valid);
pareto_v      = pareto_v(:, valid);

fprintf('=== PARETO FRONTIER: %d feasible points traced ===\n\n', ...
    sum(valid));


%% ========================================================================
%  SECTION 5 — THREE SCENARIO ANALYSIS
% =========================================================================

n_valid = sum(valid);

%Identify knee: normalise both objectives, 
% find min Euclidean dist to origin
profit_norm = (pareto_profit - min(pareto_profit)) / ...
              (max(pareto_profit) - min(pareto_profit));
co2_norm    = (pareto_co2 - min(pareto_co2)) / ...
              (max(pareto_co2) - min(pareto_co2));
% Knee = closest to (1, 0) — max profit AND min CO2 on normalised scale
dist_to_ideal = sqrt((1 - profit_norm).^2 + co2_norm.^2);
[~, knee_idx] = min(dist_to_ideal);

% Scenario indices
s_maxprofit = n_valid;         % last point = highest profit
s_knee      = knee_idx;
s_mince2    = 1;               % first point = lowest CO2

scenarios = [s_mince2, s_knee, s_maxprofit];
scenario_labels = {'S1: Min CO₂', 'S2: Balanced (Knee)', 'S3: Max Profit'};

fprintf('%-25s  %12s  %12s  %12s  %12s\n', ...
    'Scenario', 'Profit (¥)', 'CO2 (kg)', ...
    'vs Baseline ΔProfit', 'vs Baseline ΔCO2');
fprintf('%s\n', repmat('-',1,78));
for s = 1:3
    idx = scenarios(s);
    p   = pareto_profit(idx);
    c   = pareto_co2(idx);
    dp  = p - baseline_profit;
    dc  = c - baseline_co2;
    fprintf('%-25s  %12.0f  %12.4f  %+12.0f  %+12.4f\n', ...
        scenario_labels{s}, p, c, dp, dc);
end
fprintf('\n');

for s = 1:3
    idx = scenarios(s);
    v_s = pareto_v(:, idx);

    fprintf('\n══════════════════════════════════════════\n');
    fprintf('  %s\n', scenario_labels{s});
    fprintf('  Total Profit: ¥%.0f/week  |  Total CO2: %.4f kg/week\n', ...
        pareto_profit(idx), pareto_co2(idx));
    fprintf('══════════════════════════════════════════\n');
    fprintf('%-28s  %8s  %8s  %8s  %8s  %8s\n', ...
        'Menu Item', 'Vol/wk', 'vs Base', 'Profit¥', 'CO2(kg)', 'Margin%');
    fprintf('%s\n', repmat('-',1,80));

    for m = 1:n_menu
        delta = v_s(m) - weekly_vol(m);
        margin_pct = 100 * profit_per_drink(m) / sell_price(m);
        fprintf('%-28s  %8.0f  %+8.0f  %8.0f  %8.5f  %7.1f%%\n', ...
            menu_names{m}, v_s(m), delta, ...
            profit_per_drink(m) * v_s(m), ...
            co2_per_drink(m)    * v_s(m), ...
            margin_pct);
    end

    % Category summary
    coffee_profit = sum(profit_per_drink(idx_coffee) .* v_s(idx_coffee));
    tea_profit    = sum(profit_per_drink(idx_tea)    .* v_s(idx_tea));
    coffee_co2    = sum(co2_per_drink(idx_coffee)    .* v_s(idx_coffee));
    tea_co2       = sum(co2_per_drink(idx_tea)       .* v_s(idx_tea));
    coffee_share  = sum(v_s(idx_coffee)) / sum(v_s) * 100;
    tea_share     = sum(v_s(idx_tea))    / sum(v_s) * 100;

    fprintf('%s\n', repmat('-',1,80));
    fprintf(['  Coffee total  : Profit ¥%-8.0f  CO2 %8.4f kg' ...
        '  Share %5.1f%%\n'], coffee_profit, coffee_co2, coffee_share);
    fprintf(['  Tea total     : Profit ¥%-8.0f  CO2 %8.4f kg' ...
        '  Share %5.1f%%\n'], tea_profit, tea_co2, tea_share);
end

fprintf('\n=== PROCUREMENT IMPACT — KEY INGREDIENTS ===\n');
fprintf('(Weekly grams of each ingredient required by each scenario)\n\n');

v_scenarios = [weekly_vol, pareto_v(:, scenarios(1)), ...
               pareto_v(:, scenarios(2)), pareto_v(:, scenarios(3))];

% Weekly ingredient requirements: grams (34 × 4)
ingr_weekly_g = R * v_scenarios;

fprintf('%-22s  %10s  %10s  %10s  %10s\n', ...
    'Ingredient', 'Baseline', 'S1 MinCO2', 'S2 Balanced', 'S3 MaxProfit');
fprintf('%s\n', repmat('-',1,66));

for i = 1:n_ingr
    row = ingr_weekly_g(i, :);
    if any(row > 0)
        fprintf('%-22s  %10.1f  %10.1f  %10.1f  %10.1f  g\n', ...
            ingr_names{i}, row(1), row(2), row(3), row(4));
    end
end


%% ========================================================================
%  SECTION 6 — COFFEE ORIGIN CARBON BENCHMARK
% =========================================================================

fprintf(['\n\n=== COFFEE ORIGIN CARBON RANKING (transport CO2/g,' ...
    ' air freight) ===\n']);
fprintf('%-20s  %8s  %10s  %10s  %8s\n', ...
    'Origin', 'SKUs (#)', 'Dist (km)', 'CO2/g (kg)', 'Rank');
fprintf('%s\n', repmat('-',1,64));

origin_names = {'Ethiopia'; 'Panama'; 'Colombia'; 'Costa Rica';
    'Honduras';'Kenya'; 'Ecuador'; 'Nicaragua'; 'Guatemala'; 'Rwanda';
    'Indonesia'; 'China'};
origin_skus  = [10;  8;  8;  6;  3;  3;  3;  2;  2;  1;  1;  1];
origin_dist  = [10400; 13600; 14500; 8000; 12600; 11500; 14500; ...
                12700; 12000; 11900; 5500; 2100];
origin_co2g  = origin_dist * 0.000608 / 1000;   % air, kg CO2 per gram, 
% (cross-checked with sheet)

[origin_co2g_sorted, sort_idx] = sort(origin_co2g);
for r = 1:length(origin_names)
    i = sort_idx(r);
    fprintf('%-20s  %8d  %10d  %10.5f  %8d\n', ...
        origin_names{i}, origin_skus(i), origin_dist(i), ...
        origin_co2g(i), r);
end

%% ========================================================================
%  SECTION 7 — FIGURES
% =========================================================================

% Figure 1: Pareto Frontier
figure('Name','Pareto Frontier','Position',[100 100 820 520]);
plot(pareto_co2, pareto_profit/1000, 'b-o', ...
     'LineWidth', 2, 'MarkerSize', 5, 'MarkerFaceColor','b');
hold on;

% Mark the three scenarios
colors_s = {[0.1 0.6 0.1], [0.9 0.5 0.0], [0.8 0.1 0.1]};
for s = 1:3
    idx = scenarios(s);
    scatter(pareto_co2(idx), pareto_profit(idx)/1000, 120, ...
        colors_s{s}, 'filled', 'DisplayName', scenario_labels{s});
end

% Mark baseline
scatter(baseline_co2, baseline_profit/1000, 120, 'k', 'd', ...
    'LineWidth', 2, 'DisplayName', 'Baseline (observed)');

xlabel('Weekly CO₂ Emissions (kg)', 'FontSize', 12);
ylabel('Weekly Gross Profit (¥ thousands)', 'FontSize', 12);
title({'Coffee Shop — Profit vs. CO₂ Pareto Frontier'; ...
       '(transport emissions only; menu-item volume optimization)'}, ...
    'FontSize', 13);
legend('Pareto frontier', scenario_labels{:}, 'Baseline (observed)', ...
    'Location', 'southeast', 'FontSize', 10);
grid on; box on;
xlim([min(pareto_co2)*0.95, max(pareto_co2)*1.05]);

% Annotate scenarios
for s = 1:3
    idx = scenarios(s);
    text(pareto_co2(idx) + 0.3, pareto_profit(idx)/1000 - 5, ...
        sprintf('  %s', scenario_labels{s}), ...
        'FontSize', 9, 'Color', colors_s{s});
end

% Figure 2: Volume mix comparison across 3 scenarios
figure('Name','Volume Mix by Scenario','Position',[100 680 1000 440]);

v_matrix = [weekly_vol, ...
            pareto_v(:, scenarios(1)), ...
            pareto_v(:, scenarios(2)), ...
            pareto_v(:, scenarios(3))];

bar_labels = {'Baseline', 'S1: Min CO₂', 'S2: Balanced', 'S3: Max Profit'};
b = bar(v_matrix', 'grouped');
colors = [
    0.902 0.624 0.000;
    0.337 0.706 0.914;
    0.000 0.620 0.451;
    0.941 0.894 0.259;
    0.000 0.447 0.698;
    0.835 0.369 0.000;
    0.800 0.475 0.655;
    0.000 0.000 0.000;
    0.600 0.600 0.600;
    0.400 0.761 0.647;
    0.988 0.553 0.384;
    0.553 0.627 0.796;
    0.702 0.702 0.000;
    0.745 0.729 0.855;
    0.580 0.404 0.741;
    0.902 0.161 0.541;
    0.340 0.780 0.220;
    0.871 0.561 0.019;
    0.200 0.200 0.600;
];
for k = 1:19
    b(k).FaceColor = colors(k, :);
end
set(gca, 'XTickLabel', bar_labels, 'FontSize', 10);
ylabel('Weekly Volume (drinks)', 'FontSize', 11);
title('Menu Mix: Baseline vs. Pareto Scenarios', 'FontSize', 12);
legend(menu_names, 'Location', 'eastoutside', 'FontSize', 7.5);
grid on; box on;

% Figure 3: Profit & CO2 contribution by category per scenario
figure('Name','Category Breakdown','Position',[950 100 720 500]);

categories   = {'Coffee', 'Tea'};
cat_idx      = {idx_coffee, idx_tea};
scen_labels  = {'Baseline', 'S1: Min CO₂', 'S2: Balanced', ...
    'S3: Max Profit'};
v_all        = [weekly_vol, pareto_v(:, scenarios(1)), ...
                pareto_v(:, scenarios(2)), pareto_v(:, scenarios(3))];

cat_profit = zeros(2, 4);
cat_co2    = zeros(2, 4);
for c = 1:2
    for sc = 1:4
        cat_profit(c,sc) = sum(profit_per_drink(cat_idx{c}) ...
            .* v_all(cat_idx{c},sc)) / 1000;
        cat_co2(c,sc)    = sum(co2_per_drink(cat_idx{c}) ...
            .* v_all(cat_idx{c},sc));
    end
end

subplot(1,2,1);
bar(cat_profit', 'stacked');
set(gca, 'XTickLabel', scen_labels, 'FontSize', 9);
ylabel('Gross Profit (¥ thousands)','FontSize',10);
title('Profit by Category','FontSize',11);
legend(categories,'Location','northwest','FontSize',9); grid on;

subplot(1,2,2);
bar(cat_co2', 'stacked');
set(gca, 'XTickLabel', scen_labels, 'FontSize', 9);
ylabel('CO₂ Emissions (kg)','FontSize',10);
title('Carbon by Category','FontSize',11);
legend(categories,'Location','northwest','FontSize',9); grid on;

sgtitle('Coffee vs. Tea: Profit & CO₂ Breakdown by Scenario', ...
    'FontSize', 12);

% Figure 4: Origin carbon ranking bar chart
figure('Name','Origin Carbon Ranking','Position',[950 600 680 420]);

[co2_sorted, s_idx] = sort(origin_co2g);
names_sorted = origin_names(s_idx);
skus_sorted  = origin_skus(s_idx);

b2 = barh(co2_sorted * 1000, 0.6);   % convert to g CO2 per kg (×1000)
b2.FaceColor = 'flat';
% Color by SKU count (darker = more common)
max_sku = max(skus_sorted);
for r = 1:length(names_sorted)
    intensity = 0.2 + 0.7 * (1 - (skus_sorted(r)-1)/(max_sku-1));
    b2.CData(r,:) = [0.0, 0.3*intensity, 0.8*intensity];
end

set(gca, 'YTickLabel', names_sorted, 'FontSize', 10);
xlabel('Transport CO₂ (g CO₂ per kg of coffee)', 'FontSize', 10);
title({'Coffee Origin Carbon Intensity (air freight)', ...
       'Bar color: lighter = fewer SKUs in market survey'}, ...
       'FontSize', 11);
grid on; box on;

% Add SKU count labels
for r = 1:length(names_sorted)
    if skus_sorted(r) == 1
        sku_label = sprintf('%d SKU', skus_sorted(r));
    else
        sku_label = sprintf('%d SKUs', skus_sorted(r));
    end
    text(co2_sorted(r)*1000 + 0.3, r, sku_label, ...
        'FontSize', 8, 'VerticalAlignment', 'middle');
end