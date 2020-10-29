within Buildings.Applications.DHC.CentralPlants.Heating.Generation1.Subsystems;
model CondensateSubsystem
  "Condensate subsystem with a storage tank and parallel pumps"
  extends Buildings.Fluid.Interfaces.PartialTwoPortInterface(
    final m_flow_nominal=mCW_flow_nominal);

  parameter Integer num=2 "The number of pumps";

  // Nominal Conditions
  parameter Modelica.SIunits.HeatFlowRate QCWTan_flow_nominal
    "Nominal condensate water tank heat flow rate"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.MassFlowRate mCW_flow_nominal
    "Nominal condensate water mass flow rate";
  parameter Modelica.SIunits.PressureDifference dpCWPum_nominal(
     displayUnit="Pa",
     min=0)
    "Nominal pressure drop of condensate water pump";

  // Dynamics
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation(Evaluate=true, Dialog(tab = "Dynamics", group="Equations"));

  // Initialization
  parameter Medium.Temperature T_start = Medium.T_default
    "Start value of inflow temperature"
    annotation(Dialog(tab = "Initialization"));

  // Pump parameters
  replaceable parameter Buildings.Fluid.Movers.Data.Generic perCWPum
    constrainedby Buildings.Fluid.Movers.Data.Generic
    "Performance data of condenser water pump"
    annotation (Dialog(group="Pump"),choicesAllMatching=true,
      Placement(transformation(extent={{-78,82},{-62,98}})));

  // Tank parameters
  parameter Modelica.SIunits.ThermalConductance UA=0.05*QCWTan_flow_nominal/30
    "Overall UA value";
  parameter Modelica.SIunits.Volume VWat = 1.5E-6*QCWTan_flow_nominal
    "Water volume of boiler"
    annotation(Dialog(tab = "Dynamics", enable = not (energyDynamics == Modelica.Fluid.Types.Dynamics.SteadyState)));
  parameter Modelica.SIunits.Mass mDry = 1.5E-3*QCWTan_flow_nominal
    "Mass of boiler that will be lumped to water heat capacity"
    annotation(Dialog(tab = "Dynamics", enable = not (energyDynamics == Modelica.Fluid.Types.Dynamics.SteadyState)));

  // Valve parameters
  parameter Real threshold(min = 0.01) = 0.05
    "Hysteresis threshold";

  Buildings.Applications.DataCenters.ChillerCooled.Equipment.FlowMachine_y pum(
    redeclare package Medium = Medium,
    final per=fill(perCWPum, num),
    final m_flow_nominal=mCW_flow_nominal,
    final dpValve_nominal=dpCWPum_nominal,
    final num=num,
    threshold=threshold) "Speed controlled pump"
    annotation (Placement(transformation(extent={{20,-10},{40,10}})));
  Buildings.Fluid.Sources.Boundary_pT watSou(
    redeclare package Medium = Medium,
    nPorts=1) "Water source"
    annotation (Placement(transformation(extent={{-90,20},{-70,40}})));
  Modelica.Blocks.Interfaces.RealOutput P_ConWatPum[num](
    each final quantity= "Power",
    each final unit="W") "Electrical power consumed by the pumps"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}}, origin={
            110,40})));
  Modelica.Blocks.Interfaces.RealInput u[num](
    each final unit="1",
    each max=1,
    each min=0)
    "Continuous input signal for the flow machine"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}}),
      iconTransformation(extent={{-140,40},{-100,80}})));

  Buildings.Fluid.Sensors.MassFlowRate senMasFlo(redeclare package Medium =
        Medium)                                  "Mass flow sensor for make up water"
    annotation (Placement(transformation(extent={{-60,20},{-40,40}})));
  Modelica.Blocks.Interfaces.RealOutput mMUW_flow(
    quantity="MassFlowRate",
    final unit="kg/s") "Make up water mass flow rate"
    annotation (Placement(transformation(extent={{100,70},{120,90}})));
  Buildings.Fluid.MixingVolumes.MixingVolume conStoTan(
    redeclare package Medium = Medium,
    m_flow_nominal=mCW_flow_nominal,
    V=VWat,
    nPorts=3)
    "Condensate storage tank"
    annotation (Placement(transformation(extent={{-40,0},{-20,-20}})));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor heaCapDry(C=500*mDry,
      T(start=T_start)) if not (energyDynamics == Modelica.Fluid.Types.Dynamics.SteadyState)
    "heat capacity of condensate tank"
    annotation (Placement(transformation(extent={{-10,-60},{10,-80}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort
    "Heat port, can be used to connect to ambient"
    annotation (Placement(transformation(extent={{-10,90},{10,110}})));
  Fluid.FixedResistances.CheckValve cheVal(
    redeclare package Medium = Medium,
    m_flow_nominal=mCW_flow_nominal*0.01,
    dpValve_nominal=6000)
    annotation (Placement(transformation(extent={{-30,20},{-10,40}})));
protected
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor UAOve(G=UA)
    "Overall thermal conductance (if heatPort is connected)"
    annotation (Placement(transformation(extent={{-40,-60},{-20,-40}})));
equation
  connect(pum.port_b, port_b)
    annotation (Line(points={{40,0},{100,0}}, color={0,127,255}));
  connect(pum.P, P_ConWatPum) annotation (Line(points={{41,4},{80,4},{80,40},{
          110,40}}, color={0,0,127}));
  connect(u, pum.u) annotation (Line(points={{-120,60},{10,60},{10,4},{18,4}},
        color={0,0,127}));
  connect(watSou.ports[1], senMasFlo.port_a)
    annotation (Line(points={{-70,30},{-60,30}},   color={0,127,255}));
  connect(senMasFlo.m_flow, mMUW_flow)
    annotation (Line(points={{-50,41},{-50,80},{110,80}},  color={0,0,127}));
  connect(port_a, conStoTan.ports[1])
    annotation (Line(points={{-100,0},{-32.6667,0}}, color={0,127,255}));
  connect(conStoTan.ports[2], pum.port_a)
    annotation (Line(points={{-30,0},{20,0}}, color={0,127,255}));
  connect(conStoTan.heatPort, UAOve.port_a) annotation (Line(points={{-40,-10},
          {-52,-10},{-52,-50},{-40,-50}}, color={191,0,0}));
  connect(UAOve.port_b, heatPort)
    annotation (Line(points={{-20,-50},{0,-50},{0,100}}, color={191,0,0}));
  connect(heaCapDry.port, heatPort)
    annotation (Line(points={{0,-60},{0,100}}, color={191,0,0}));
  connect(senMasFlo.port_b, cheVal.port_a)
    annotation (Line(points={{-40,30},{-30,30}}, color={0,127,255}));
  connect(conStoTan.ports[3], cheVal.port_b) annotation (Line(points={{-27.3333,
          0},{-27.3333,8},{-4,8},{-4,30},{-10,30}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Ellipse(
          extent={{-72,-34},{-20,-46}},
          lineColor={0,0,0},
          fillColor={166,166,166},
          fillPattern=FillPattern.Sphere),
        Rectangle(
          extent={{12,54},{68,42}},
          lineColor={0,0,0},
          fillColor={0,127,255},
          fillPattern=FillPattern.HorizontalCylinder),
        Rectangle(
          extent={{-96,6},{-66,-6}},
          lineColor={0,0,0},
          fillColor={0,127,255},
          fillPattern=FillPattern.HorizontalCylinder),
        Rectangle(
          extent={{70,6},{100,-6}},
          lineColor={0,0,0},
          fillColor={0,127,255},
          fillPattern=FillPattern.HorizontalCylinder),
        Rectangle(
          extent={{12,-48},{68,-60}},
          lineColor={0,0,0},
          fillColor={0,127,255},
          fillPattern=FillPattern.HorizontalCylinder),
        Rectangle(
          extent={{-57,6},{57,-6}},
          lineColor={0,0,0},
          fillColor={0,127,255},
          fillPattern=FillPattern.HorizontalCylinder,
          origin={6,-3},
          rotation=90),
        Rectangle(
          extent={{-57,6},{57,-6}},
          lineColor={0,0,0},
          fillColor={0,127,255},
          fillPattern=FillPattern.HorizontalCylinder,
          origin={74,-3},
          rotation=90),
        Rectangle(
          extent={{-30,6},{0,-6}},
          lineColor={0,0,0},
          fillColor={0,127,255},
          fillPattern=FillPattern.HorizontalCylinder),
        Ellipse(
          extent={{20,70},{60,30}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Sphere,
          fillColor={0,100,199}),
        Polygon(
          points={{40,70},{40,30},{60,50},{40,70}},
          lineColor={0,0,0},
          pattern=LinePattern.None,
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={255,255,255}),
        Ellipse(
          extent={{42,56},{54,44}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Sphere,
          visible=energyDynamics <> Modelica.Fluid.Types.Dynamics.SteadyState,
          fillColor={0,100,199}),
        Ellipse(
          extent={{22,-32},{62,-72}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Sphere,
          fillColor={0,100,199}),
        Polygon(
          points={{42,-32},{42,-72},{62,-52},{42,-32}},
          lineColor={0,0,0},
          pattern=LinePattern.None,
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={255,255,255}),
        Ellipse(
          extent={{44,-46},{56,-58}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Sphere,
          visible=energyDynamics <> Modelica.Fluid.Types.Dynamics.SteadyState,
          fillColor={0,100,199}),
        Rectangle(
          extent={{-72,40},{-20,-40}},
          fillColor={166,166,166},
          fillPattern=FillPattern.VerticalCylinder,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Line(points={{-72,40},{-72,-40}}, color={0,0,0}),
        Line(points={{-20,40},{-20,-40}},
                                        color={0,0,0}),
        Ellipse(
          extent={{-72,46},{-20,34}},
          lineColor={0,0,0},
          fillColor={166,166,166},
          fillPattern=FillPattern.Sphere),
        Line(points={{-46,46},{-46,80},{0,80},{0,90}}, color={238,46,47})}),
                                                                 Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end CondensateSubsystem;
