close all

% define indoor dimensions
inside_length = 6;
inside_width = 6;
inside_height = 3;

% define insulation parameters
insulation_thickness = 0.18;
insulation_conductivity = 0.043;

% calculate outdoor dimensions
outside_length = inside_length + insulation_thickness*2;
outside_width = inside_width + insulation_thickness*2;
outside_height = inside_height + insulation_thickness*2;

% define floor properties
floor_height = 0.1;
floor_density = 3000;
floor_specific_heat_capacity = 800;
floor_volume = inside_length*inside_width*floor_height;
floor_surface_area = 2*(inside_length*inside_width + inside_length*floor_height + inside_width*floor_height);

% define heat transfer coefficients
h_indoor = 15;
h_outdoor = 30;
h_window = 1.4;

% define air properties
inside_air_volume = inside_length*inside_width*(inside_height-floor_height);
air_density = 1.2;
air_specific_heat_capacity = 1012;

% calculate relevant areas
inside_wall_area = 2*(inside_length*inside_width + inside_length*inside_height) + inside_width*inside_height;
window_area = inside_width*(inside_height/5);
outside_wall_area = 2*(outside_length*outside_width + outside_length*outside_height + outside_width*outside_height) - window_area;

% calculate thermal resistances
floor_to_inside_resistance = 1/(h_indoor*floor_surface_area);
inside_to_outside_wall_resistance = 1/(h_indoor*inside_wall_area) + insulation_thickness/(insulation_conductivity*inside_wall_area) + ...
    1/(h_outdoor*outside_wall_area);
inside_to_outside_window_resistance = 1/(h_window*window_area);
inside_to_outside_total_resistance = 1/(1/inside_to_outside_wall_resistance + 1/inside_to_outside_window_resistance);

% calculate heat capacities
floor_heat_capacity = floor_density*floor_volume*floor_specific_heat_capacity;
inside_air_heat_capacity = air_density*inside_air_volume*air_specific_heat_capacity;

% create ODEs
% T(1) is floor temperature, T(2) is inside air temperature
[t, T] = ode45(@(t, T) [((-361.*cos(pi.*t./(12.*3600)) + 224.*cos(pi.*t./(6.*3600)) + 210)*window_area - ((T(1)-T(2))./floor_to_inside_resistance))./floor_heat_capacity; ...
    ((T(1)-T(2))./floor_to_inside_resistance - (T(2)-(4.5.*sin(pi.*(t-32400)./43200)-1.5))./inside_to_outside_total_resistance)./inside_air_heat_capacity], ...
    linspace(0, 3000000, 900), [-4.682, -4.682]);

% plot inside air temperature over time
plot(t./(60*60*24), T(:,2), lineWidth=1.5)
legend("Inside Air Temperature", Location="se");
xlabel("Time (days)")
ylabel("Temperature (°C)")
title("House Temperature over Time")

figure
% plot single day temperature
plot(t(1:27)./3600, T(480:506,2), lineWidth=1.5)
xlim([0, 24])
xticks(linspace(0, 24, 13))
title("Single Day Temperature")
xlabel("Time (hours from noon)")
ylabel("Temperature (°C)")
hold on
plot([0, 24], [max(T(480:506,2)), max(T(480:506,2))], "k--")
plot([0, 24], [min(T(480:506,2)), min(T(480:506,2))], "r--")
max_label = "Max Temp: %g°C";
min_label = "Min Temp: %g°C";
legend(["Air Temperature", sprintf(max_label, round(max(T(480:506,2)),2)), sprintf(min_label, round(min(T(480:506,2)),2))])
hold off

