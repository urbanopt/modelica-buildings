within Buildings.Applications.DHC.CentralPlants.Heating.Generation1.Subsystems.Examples;
model CondensateSubsystem
  "Example model for the condensate subsystem"
  extends Modelica.Icons.Example;

  package Medium = Buildings.Media.Water "Medium model";
  parameter Integer numPum=2 "The number of pumps";
  parameter Modelica.SIunits.MassFlowRate mCW_flow_nominal=6000/3600*1.2
    "Nominal mass flow rate";
  parameter Modelica.SIunits.PressureDifference dpCW_nominal=46.2*1000
    "Nominal condenser water side pressure";
  parameter Real thr=1E-4 "Threshold for shutoff valves in parallel";

  //pumps
  parameter Buildings.Fluid.Movers.Data.Generic perCWPum(
    pressure=Buildings.Fluid.Movers.BaseClasses.Characteristics.flowParameters(
      V_flow=mCW_flow_nominal/1000*{0.2,0.6,1.0,1.2},
      dp=(dpCW_nominal+60000+6000)*{1.2,1.1,1.0,0.6}))
    "Performance data for condenser water pumps";

  Buildings.Applications.DHC.CentralPlants.Heating.Generation1.Subsystems.CondensateSubsystem
    conSubSys(
    redeclare package Medium = Medium,
    QCWTan_flow_nominal=mCW_flow_nominal*60,
    mCW_flow_nominal=mCW_flow_nominal,
    dpCWPum_nominal=dpCW_nominal,
    num=numPum,
    perCWPum=perCWPum,
    threshold=thr)
              "Condensate subsystem"
    annotation (Placement(transformation(extent={{0,0},{20,20}})));
  Fluid.Sources.Boundary_pT           sou(
    redeclare package Medium = Medium,
    use_p_in=false,
    p=101325,
    T=353.15,
    nPorts=1)
    "Source"
    annotation (Placement(transformation(extent={{-90,0},{-70,20}})));
  Fluid.Sources.Boundary_pT           sin(
    redeclare package Medium = Medium,
    use_p_in=false,
    p=101325,
    T=353.15,
    nPorts=1)
    "Sink"
    annotation (Placement(transformation(extent={{90,0},{70,20}})));
  Modelica.Blocks.Sources.Pulse y[numPum](
    each amplitude=1,
    each width=50,
    each period=120,
    each offset=0,
    each startTime=0) "Input signal"
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  HeatTransfer.Sources.FixedTemperature TAmb(T=293.15)
    "Ambient room temperature"
    annotation (Placement(transformation(extent={{-20,60},{0,80}})));
  Fluid.FixedResistances.PressureDrop           dp2(
    redeclare package Medium = Medium,
    dp_nominal=3000,
    m_flow_nominal=mCW_flow_nominal)
    "Pressure drop"
    annotation (Placement(transformation(extent={{40,0},{60,20}})));
  Fluid.FixedResistances.PressureDrop           dp1(
    redeclare package Medium = Medium,
    m_flow_nominal=mCW_flow_nominal,
    dp_nominal=300)
    "Pressure drop"
    annotation (Placement(transformation(extent={{-50,0},{-30,20}})));
equation
  connect(TAmb.port, conSubSys.heatPort)
    annotation (Line(points={{0,70},{10,70},{10,20}}, color={191,0,0}));
  connect(y.y, conSubSys.u) annotation (Line(points={{-59,70},{-40,70},{-40,16},
          {-2,16}}, color={0,0,127}));
  connect(sou.ports[1], dp1.port_a)
    annotation (Line(points={{-70,10},{-50,10}}, color={0,127,255}));
  connect(dp1.port_b, conSubSys.port_a)
    annotation (Line(points={{-30,10},{0,10}}, color={0,127,255}));
  connect(conSubSys.port_b, dp2.port_a)
    annotation (Line(points={{20,10},{40,10}}, color={0,127,255}));
  connect(dp2.port_b, sin.ports[1])
    annotation (Line(points={{60,10},{70,10}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
  __Dymola_Commands(file=
    "modelica://Buildings/Resources/Scripts/Dymola/Applications/DHC/CentralPlants/Heating/Generation1/Subsystems/Examples/CondensateSubsystem.mos"
    "Simulate and plot"),
  experiment(
    StartTime=0,
    StopTime=360,
    Tolerance=1e-06));
end CondensateSubsystem;
