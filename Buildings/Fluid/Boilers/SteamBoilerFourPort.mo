within Buildings.Fluid.Boilers;
model SteamBoilerFourPort
  "Model for a steam boiler with four ports for air and water flows, including medium changes"
  extends Buildings.Fluid.Interfaces.PartialFourPortFourMedium(
    redeclare final package Medium_a1 = MediumWat,
    redeclare final package Medium_b1 = MediumSte,
    redeclare final package Medium_a2 = MediumAir,
    redeclare final package Medium_b2 = MediumAir);
  extends Buildings.Fluid.Boilers.BaseClasses.PartialSteamBoiler(
    redeclare final package Medium_a = MediumWat,
    redeclare final package Medium_b = MediumSte,
    final m_flow_nominal = m1_flow_nominal,
    vol(
      m_flow_small=m1_flow_small,
      V=m1_flow_nominal*tau/rho_default),
    eva(final m_flow_nominal=m1_flow_nominal, m_flow_small=m1_flow_small,
      pSte_nominal=pBoi_nominal),
    dpCon(
      m_flow_nominal=m1_flow_nominal,
      m_flow_small=m1_flow_small,
      addPowerToMedium=false,
      nominalValuesDefineDefaultPressureCurve=true));

  replaceable package MediumWat =
      Modelica.Media.Interfaces.PartialMedium
    "Medium model for liquid water";
  replaceable package MediumSte =
      IBPSA.Media.Interfaces.PartialPureSubstanceWithSat
    "Medium model air water vapor";
  replaceable package MediumAir =
      Modelica.Media.Interfaces.PartialMedium
    "Medium model for air";

  parameter Real ratAirFue = 10
    "Air-to-fuel ratio (by volume)";

  BaseClasses.Combustion com(
    m_flow_nominal=m2_flow_nominal,
    redeclare final package Medium = MediumAir,
    final show_T = show_T) "Combustion process"
    annotation (Placement(transformation(extent={{-40,-90},{-60,-70}})));
  FixedResistances.PressureDrop preDroAir(
    redeclare package Medium = MediumAir,
    m_flow_nominal=m2_flow_nominal,
    dp_nominal=1400,
    final show_T = show_T) "Air side total pressure drop"
    annotation (Placement(transformation(extent={{40,-90},{20,-70}})));
equation
  connect(port_a2, port_a2) annotation (Line(points={{100,-60},{100,-60},{100,
          -60}},
        color={0,127,255}));
  connect(y, com.y) annotation (Line(points={{-120,100},{-88,100},{-88,-56},{
          -34,-56},{-34,-72},{-39,-72}},
                                   color={0,0,127}));
  connect(port_a1, senMasFlo.port_a) annotation (Line(points={{-100,60},{-94,60},
          {-94,0},{-80,0}}, color={0,127,255}));
  connect(temSen_out.port_b, port_b1) annotation (Line(points={{90,0},{94,0},{
          94,60},{100,60}}, color={0,127,255}));
  connect(port_a2, preDroAir.port_a) annotation (Line(points={{100,-60},{80,-60},
          {80,-80},{40,-80}}, color={0,127,255}));
  connect(preDroAir.port_b, com.port_a)
    annotation (Line(points={{20,-80},{-40,-80}}, color={0,127,255}));
  connect(com.port_b, port_b2) annotation (Line(points={{-60,-80},{-80,-80},{
          -80,-60},{-100,-60}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}),                                  graphics={
        Rectangle(
          extent={{-100,64},{74,56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{0,56},{100,64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-40,40},{40,-40}},
          fillColor={127,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-100,-56},{100,-64}},
          lineColor={244,125,35},
          pattern=LinePattern.None,
          fillColor={255,170,85},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{0,-56},{100,-64}},
          lineColor={244,125,35},
          pattern=LinePattern.None,
          fillColor={244,125,35},
          fillPattern=FillPattern.Solid),
      Line(
        points={{-2,20},{-22,10},{-2,-10},{-22,-20}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}}),
      Line(
        points={{20,20},{0,10},{20,-10},{0,-20}},
        color={238,46,47},
        smooth=Smooth.Bezier,
          extent={{-60,-22},{-36,2}})}),                         Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-100,-120},{100,
            120}})));
end SteamBoilerFourPort;
