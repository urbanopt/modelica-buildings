within Buildings.Applications.DHC.EnergyTransferStations.Heating.Generation1.Examples;
model HeatingIndirect
  "Example model for the indirect heating energy transfer station"
  extends Modelica.Icons.Example;

 package MediumWat = IBPSA.Media.WaterHighTemperature "Medium model for liquid water";
 package MediumSte = IBPSA.Media.Steam "Medium model for steam vapor";
  parameter Modelica.SIunits.Temperature T_a1_nominal = 150+273.15
    "Temperature at nominal conditions as port a1";
  parameter Modelica.SIunits.Temperature T_b1_nominal = 120+273.15
    "Temperature at nominal conditions as port b1";
  parameter Modelica.SIunits.Temperature T_a2_nominal = 20+273.15
    "Temperature at nominal conditions as port a2";
  parameter Modelica.SIunits.Temperature T_b2_nominal = 50+273.15
    "Temperature at nominal conditions as port b2";
  parameter Modelica.SIunits.AbsolutePressure pSte_nominal = 476100
    "Nominal steam pressure, saturation at T_a1_nominal";
  parameter Modelica.SIunits.Density rhoStdCon = MediumWat.density(
    MediumWat.setState_pTX(pSte_nominal,T_b1_nominal,MediumWat.X_default))
    "Condensate standard density";
  parameter Modelica.SIunits.SpecificEnthalpy dhDis_nominal=
    MediumSte.specificEnthalpy(MediumSte.setState_pTX(
      pSte_nominal,T_a1_nominal)) - MediumWat.specificEnthalpy(MediumWat.setState_pTX(
      pSte_nominal,T_b1_nominal))
    "Nominal change in enthalpy for district side";
  parameter Modelica.SIunits.SpecificEnthalpy dhBui_nominal=
    MediumWat.specificHeatCapacityCp(MediumWat.setState_pTX(
    MediumWat.p_default,
    MediumWat.T_default,
    MediumWat.X_default)) * (T_b2_nominal-T_a2_nominal)
    "Nominal change in enthalpy for building side";
  parameter Modelica.SIunits.MassFlowRate mDis_flow_nominal = 0.01
    "Nominal mass flow rate for district side";
  parameter Modelica.SIunits.MassFlowRate mBui_flow_nominal = mDis_flow_nominal*dhDis_nominal/dhBui_nominal
    "Nominal mass flow rate for building side";

  // Building load
  parameter Real Q_flow_profile[:, :]= [0, 200E3; 6, 200E3; 6, 50E3; 18, 50E3; 18, 75E3; 24, 75E3]
    "Normalized time series heating load";
  parameter Modelica.SIunits.Power Q_flow_nominal= 200E3
    "Nominal heat flow rate";

  Buildings.Applications.DHC.EnergyTransferStations.Heating.Generation1.HeatingIndirect
    ets(
    redeclare package Medium = MediumWat,
    redeclare package MediumSat = MediumSte,
    mDis_flow_nominal=mDis_flow_nominal,
    mBui_flow_nominal=mBui_flow_nominal,
    pSte_nominal=pSte_nominal,
    k=0.01,
    Ti=30)             "Ideal heating energy transfer station"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Fluid.Sources.Boundary_pT           souSte(
    redeclare package Medium = MediumSte,
    p=300000 + 9000,
    use_T_in=false,
    T=T_a1_nominal,
    nPorts=1)       "Steam source"
    annotation (Placement(transformation(extent={{-60,20},{-40,40}})));
  Fluid.Sources.Boundary_pT           sinWatHot(
    redeclare package Medium = MediumWat,
    use_p_in=false,
    p(displayUnit="Pa") = 300000,
    T=303.15,
    nPorts=1) "Hot water sink"
    annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
  Fluid.Sources.Boundary_pT           souWat(
    redeclare package Medium = MediumWat,
    use_p_in=false,
    use_T_in=false,
    p(displayUnit="Pa") = 305000,
    T=T_a2_nominal,
    nPorts=1)       "Water source"
    annotation (Placement(transformation(extent={{80,-40},{60,-20}})));
  Fluid.Sources.Boundary_pT           sinCon(
    redeclare package Medium = MediumWat,
    use_p_in=false,
    p=300000,
    T=293.15,
    nPorts=1) "Condensate sink"
    annotation (Placement(transformation(extent={{80,20},{60,40}})));
  Modelica.Blocks.Sources.Pulse TSet(
    amplitude=10,
    period=3600,
    offset=273.15 + 50) "Temperature setpoint"
    annotation (Placement(transformation(extent={{-92,-10},{-72,10}})));
equation
  connect(souSte.ports[1], ets.port_a1) annotation (Line(points={{-40,30},{-30,30},
          {-30,6},{-10,6}}, color={0,127,255}));
  connect(ets.port_b1, sinCon.ports[1]) annotation (Line(points={{10,6},{50,6},{
          50,30},{60,30}}, color={0,127,255}));
  connect(souWat.ports[1], ets.port_a2) annotation (Line(points={{60,-30},{50,-30},
          {50,-6},{10,-6}}, color={0,127,255}));
  connect(ets.port_b2, sinWatHot.ports[1]) annotation (Line(points={{-10,-6},{-30,
          -6},{-30,-30},{-40,-30}}, color={0,127,255}));
  connect(ets.TSetBuiSup, TSet.y)
    annotation (Line(points={{-12,0},{-71,0}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
  experiment(StopTime=3600, Tolerance=1e-06),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Applications/DHC/EnergyTransferStations/Heating/Generation1/Examples/HeatingIndirect.mos"
        "Simulate and plot"));
end HeatingIndirect;
