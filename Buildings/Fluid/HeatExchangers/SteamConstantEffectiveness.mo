within Buildings.Fluid.HeatExchangers;
model SteamConstantEffectiveness
  "Model for a shell-and-tube heat exchanger with phase change in one side and a prescribed constant effectiveness"
  extends Buildings.Fluid.Interfaces.PartialFourPortFourMediumCounter(
    redeclare final package Medium_b2 = Medium,
    redeclare final package Medium_a2 = Medium,
    redeclare final package Medium_b1 = Medium,
    redeclare final package Medium_a1 = MediumSat);

  replaceable package Medium =
      Modelica.Media.Interfaces.PartialMedium
    "Medium model (liquid state) for all other ports";
  replaceable package MediumSat =
      IBPSA.Media.Interfaces.PartialPureSubstanceWithSat
    "Medium model (vapor state) for port_a1 (primary inlet)";

  parameter Modelica.SIunits.Efficiency eps(max=1) = 0.8
    "Heat exchanger effectiveness";

  parameter Modelica.SIunits.AbsolutePressure pSte_nominal
    "Nominal steam pressure"
     annotation(Dialog(group="Nominal condition"));

  final parameter Modelica.SIunits.HeatFlowRate QLat_flow_nominal=
    m1_flow_nominal * MediumSat.enthalpyOfVaporization_sat(
    MediumSat.saturationState_p(pSte_nominal))
    "Nominal latent heat flow rate on the building side";

  BaseClasses.Condensation con(
    redeclare package Medium_a = MediumSat,
    redeclare package Medium_b = Medium,
    m_flow_nominal=m2_flow_nominal,
    pSte_nominal=pSte_nominal) "Condensation"
    annotation (Placement(transformation(extent={{-80,50},{-60,70}})));
  HeaterCooler_u hea(
    redeclare package Medium = Medium,
                     m_flow_nominal=m1_flow_nominal,
    dp_nominal=600,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    p_start=pSte_nominal,
    T_start=MediumSat.saturationTemperature_p(pSte_nominal),
    Q_flow_nominal=QLat_flow_nominal)
    annotation (Placement(transformation(extent={{60,-70},{40,-50}})));
  Sensors.MassFlowRate senMasFlo(redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{-50,50},{-30,70}})));
  Modelica.Blocks.Math.Product QMaxLat_flow
    "Maximum latent heat flow rate possible to transfer to building fluid"
    annotation (Placement(transformation(extent={{-20,70},{0,90}})));
  Modelica.Blocks.Math.Gain uCal(k=-eps/QLat_flow_nominal)
    "Calculated u value for heat transfer rate to district fluid"
    annotation (Placement(transformation(extent={{20,70},{40,90}})));
  ConstantEffectiveness hex(
    redeclare package Medium1 = Medium,
    redeclare package Medium2 = Medium,
    m1_flow_nominal=m1_flow_nominal,
    m2_flow_nominal=m2_flow_nominal,
    dp1_nominal=6000,
    dp2_nominal=6000,
    eps=eps) annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
equation
  connect(port_a1, con.port_a)
    annotation (Line(points={{-100,60},{-80,60}}, color={0,127,255}));
  connect(con.port_b, senMasFlo.port_a)
    annotation (Line(points={{-60,60},{-50,60}}, color={0,127,255}));
  connect(senMasFlo.port_b, hex.port_a1) annotation (Line(points={{-30,60},{-20,
          60},{-20,6},{-10,6}}, color={0,127,255}));
  connect(hex.port_b1, port_b1) annotation (Line(points={{10,6},{20,6},{20,60},{
          100,60}}, color={0,127,255}));
  connect(port_a2, hea.port_a)
    annotation (Line(points={{100,-60},{60,-60}}, color={0,127,255}));
  connect(hea.port_b, hex.port_a2) annotation (Line(points={{40,-60},{20,-60},{20,
          -6},{10,-6}}, color={0,127,255}));
  connect(hex.port_b2, port_b2) annotation (Line(points={{-10,-6},{-20,-6},{-20,
          -60},{-100,-60}}, color={0,127,255}));
  connect(QMaxLat_flow.u2, senMasFlo.m_flow)
    annotation (Line(points={{-22,74},{-40,74},{-40,71}}, color={0,0,127}));
  connect(con.dh, QMaxLat_flow.u1) annotation (Line(points={{-59,66},{-50,66},{-50,
          86},{-22,86}}, color={0,0,127}));
  connect(QMaxLat_flow.y, uCal.u)
    annotation (Line(points={{1,80},{18,80}}, color={0,0,127}));
  connect(uCal.y, hea.u) annotation (Line(points={{41,80},{70,80},{70,-54},{62,-54}},
        color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Text(
          extent={{-149,-114},{151,-154}},
          lineColor={0,0,255},
          textString="%name"),
        Rectangle(
          extent={{-80,80},{80,-80}},
          lineColor={238,46,47},
          pattern=LinePattern.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
      Line(
        points={{-52,46},{-72,36},{-52,16},{-72,6}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
      Line(
        points={{-32,46},{-52,36},{-32,16},{-52,6}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
      Line(
        points={{-12,46},{-32,36},{-12,16},{-32,6}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
        Rectangle(
          extent={{-80,80},{80,-80}},
          lineColor={0,0,127},
          lineThickness=0.5),
        Rectangle(
          extent={{-100,66},{101,53}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-102,-54},{99,-67}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid)}),                      Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end SteamConstantEffectiveness;
