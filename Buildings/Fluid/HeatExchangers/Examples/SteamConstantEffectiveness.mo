within Buildings.Fluid.HeatExchangers.Examples;
model SteamConstantEffectiveness
  extends Modelica.Icons.Example;

 package MediumWat = IBPSA.Media.Specialized.Water.HighTemperature "Medium model for liquid water";
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

  Buildings.Fluid.Sources.Boundary_pT sinWatHot(
    redeclare package Medium = MediumWat,
    use_p_in=false,
    p(displayUnit="Pa") = 300000,
    T=303.15,
    nPorts=1) "Hot water sink"
    annotation (Placement(transformation(extent={{-50,10},{-30,30}})));
  Buildings.Fluid.Sources.Boundary_pT souWat(
    redeclare package Medium = MediumWat,
    use_p_in=false,
    use_T_in=false,
    p(displayUnit="Pa") = 305000,
    T=T_a2_nominal,
    nPorts=1)       "Water source"
    annotation (Placement(transformation(extent={{140,10},{120,30}})));
  Buildings.Fluid.Sources.Boundary_pT sinCon(
    redeclare package Medium = MediumWat,
    use_p_in=false,
    p=300000,
    T=293.15,
    nPorts=1) "Condensate sink"
    annotation (Placement(transformation(extent={{180,50},{160,70}})));
  Buildings.Fluid.Sources.Boundary_pT souSte(
    redeclare package Medium = MediumSte,
    p=300000 + 9000,
    use_T_in=false,
    T=T_a1_nominal,
    nPorts=1)       "Steam source"
    annotation (Placement(transformation(extent={{-50,50},{-30,70}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort temSen(redeclare package Medium =
        MediumWat, m_flow_nominal=mBui_flow_nominal)
    "Temperature sensor"
    annotation (Placement(transformation(extent={{40,10},{20,30}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage val(
    redeclare package Medium = MediumSte,
    rhoStd=rhoStdCon,
    l=0.005,
    m_flow_nominal=mDis_flow_nominal,
    dpFixed_nominal=2000 + 3000,
    dpValve_nominal=6000) "Valve"
    annotation (Placement(transformation(extent={{120,50},{140,70}})));
  Buildings.Controls.Continuous.LimPID P(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    Ti=30,
    k=0.01,
    Td=1)
    "Controller"
    annotation (Placement(transformation(extent={{-20,80},{0,100}})));
  Modelica.Blocks.Sources.Pulse TSet(
    amplitude=10,
    period=3600,
    offset=273.15 + 50) "Temperature setpoint"
    annotation (Placement(transformation(extent={{-70,80},{-50,100}})));


  Buildings.Fluid.HeatExchangers.SteamConstantEffectiveness hex(
    m1_flow_nominal=mDis_flow_nominal,
    m2_flow_nominal=mBui_flow_nominal,
    show_T=true,
    redeclare package Medium = MediumWat,
    redeclare package MediumSat = MediumSte,
    pSte_nominal=pSte_nominal)
    annotation (Placement(transformation(extent={{70,30},{90,50}})));
equation
  connect(TSet.y, P.u_s) annotation (Line(
      points={{-49,90},{-22,90}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(temSen.T, P.u_m) annotation (Line(
      points={{30,31},{30,40},{-10,40},{-10,78}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(P.y, val.y) annotation (Line(
      points={{1,90},{130,90},{130,72}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(temSen.port_b, sinWatHot.ports[1]) annotation (Line(
      points={{20,20},{-30,20}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(souWat.ports[1], hex.port_a2) annotation (Line(points={{120,20},{118,20},
          {118,18},{100,18},{100,34},{90,34},{90,34}}, color={0,127,255}));
  connect(temSen.port_a, hex.port_b2) annotation (Line(points={{40,20},{60,20},{
          60,34},{70,34}}, color={0,127,255}));
  connect(souSte.ports[1], hex.port_a1) annotation (Line(points={{-30,60},{60,60},
          {60,46},{70,46}}, color={0,127,255}));
  connect(hex.port_b1, val.port_a) annotation (Line(points={{90,46},{100,46},{100,
          60},{120,60}}, color={0,127,255}));
  connect(val.port_b, sinCon.ports[1])
    annotation (Line(points={{140,60},{160,60}}, color={0,127,255}));
  annotation(Diagram(coordinateSystem(preserveAspectRatio=true,  extent={{-100,
            -100},{200,200}})),
experiment(Tolerance=1e-6, StopTime=3600),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/HeatExchangers/Examples/SteamConstantEffectiveness.mos"
        "Simulate and plot"),
Documentation(info="<html>
</html>",
revisions="<html>
</html>"));
end SteamConstantEffectiveness;
