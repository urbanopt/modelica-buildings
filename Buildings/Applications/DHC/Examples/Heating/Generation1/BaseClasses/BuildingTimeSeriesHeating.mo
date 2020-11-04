within Buildings.Applications.DHC.Examples.Heating.Generation1.BaseClasses;
model BuildingTimeSeriesHeating

  replaceable package Medium_a =
      IBPSA.Media.Interfaces.PartialPureSubstanceWithSat
    "Medium model (vapor state) for port_a (inlet)";
  replaceable package Medium_b =
      Modelica.Media.Interfaces.PartialMedium
    "Medium model (liquid state) for port_b (outlet)";

  parameter Modelica.SIunits.Power Q_flow_nominal=mBui_flow_nominal*cp*(50 - 30)
    "Nominal heat flow rate";

  parameter Modelica.SIunits.AbsolutePressure pSte_nominal
    "Nominal steam pressure";
//  final parameter Modelica.SIunits.SpecificEnthalpy dh_nominal=
//    Medium_a.enthalpyOfVaporization_sat(Medium_a.saturationState_p(pSte_nominal))
//    "Nominal change in enthalpy";
  parameter Modelica.SIunits.MassFlowRate mDis_flow_nominal(
    final min=0,
    final start=0.5)
    "Nominal mass flow rate of primary (district) district cooling side";
  parameter Modelica.SIunits.MassFlowRate mBui_flow_nominal(
    final min=0,
    final start=0.5)
    "Nominal mass flow rate of secondary (building) district cooling side";
  parameter Modelica.SIunits.Temperature TBuiSupSet=50+273.15
    "Building hot water supply temperature setpoint";
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation(Evaluate=true, Dialog(tab = "Dynamics", group="Equations"));
  parameter Modelica.SIunits.Time tau = 30
    "Time constant at nominal flow (if energyDynamics <> SteadyState)"
     annotation (Dialog(tab = "Dynamics", group="Nominal condition"));


  // Table parameters
  parameter Boolean tableOnFile=false
    "= true, if table is defined on file or in function usertab"
    annotation (Dialog(group="Table data definition"));
  parameter Real QHeaLoa[:, :] = fill(0.0, 0, 2)
    "Table matrix (time = first column; e.g., table=[0, 0; 1, 1; 2, 4])"
    annotation (Dialog(group="Table data definition",enable=not tableOnFile));
  parameter String tableName="NoName"
    "Table name on file or in function usertab (see docu)"
    annotation (Dialog(group="Table data definition",enable=tableOnFile));
  parameter String fileName="NoName" "File where matrix is stored"
    annotation (Dialog(
      group="Table data definition",
      enable=tableOnFile,
      loadSelector(filter="Text files (*.txt);;MATLAB MAT-files (*.mat)",
          caption="Open file in which table is present")));
  parameter Integer columns[:]=2:size(QHeaLoa, 2)
    "Columns of table to be interpolated"
    annotation (Dialog(group="Table data interpretation"));
  parameter Modelica.Blocks.Types.Smoothness smoothness=Modelica.Blocks.Types.Smoothness.LinearSegments
    "Smoothness of table interpolation"
    annotation (Dialog(group="Table data interpretation"));
  parameter Modelica.SIunits.Time timeScale(
    min=Modelica.Constants.eps)=1 "Time scale of first table column"
    annotation (Dialog(group="Table data interpretation"), Evaluate=true);

  parameter Modelica.SIunits.Time riseTime=120
    "Rise time of the filter (time to reach 99.6 % of an opening step)";

  // Diagnostics
   parameter Boolean show_T = false
    "= true, if actual temperature at port is computed"
    annotation(Dialog(tab="Advanced",group="Diagnostics"));

  Medium_a.ThermodynamicState sta_a=
      Medium_a.setState_phX(port_a.p,
                          noEvent(actualStream(port_a.h_outflow)),
                          noEvent(actualStream(port_a.Xi_outflow))) if show_T
    "Medium properties in port_a";

  Medium_b.ThermodynamicState sta_b=
      Medium_b.setState_phX(port_b.p,
                          noEvent(actualStream(port_b.h_outflow)),
                          noEvent(actualStream(port_b.Xi_outflow))) if show_T
    "Medium properties in port_b";

  Modelica.Blocks.Sources.CombiTimeTable QHea(
    tableOnFile=tableOnFile,
    table=QHeaLoa,
    tableName=tableName,
    fileName=fileName,
    columns=columns,
    smoothness=smoothness,
    timeScale=timeScale)
    "Heating demand"
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  Buildings.Applications.DHC.EnergyTransferStations.Heating.Generation1.HeatingIndirect
    ets(
    redeclare package Medium = Medium_b,
    redeclare package MediumSat = Medium_a,
    mDis_flow_nominal=mDis_flow_nominal,
    mBui_flow_nominal=mBui_flow_nominal,
    pSte_nominal=pSte_nominal) "Energy transfer station"
    annotation (Placement(transformation(extent={{40,-40},{60,-20}})));

  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare package Medium = Medium_a)
    annotation (Placement(transformation(extent={{90,-70},{110,-50}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare package Medium = Medium_b)
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  Modelica.Blocks.Sources.Ramp ram(duration=120)
    annotation (Placement(transformation(extent={{-80,20},{-60,40}})));
  Modelica.Blocks.Math.Product pro
    annotation (Placement(transformation(extent={{-40,40},{-20,60}})));
  Fluid.Movers.FlowControlled_m_flow           pum(
    redeclare replaceable package Medium = Medium_b,
    energyDynamics=energyDynamics,
    m_flow_nominal=mBui_flow_nominal,
    addPowerToMedium=false,
    nominalValuesDefineDefaultPressureCurve=true,
    constantMassFlowRate=mBui_flow_nominal)
    "Building primary pump"
    annotation (Placement(transformation(extent={{18,-48},{-2,-28}})));
  Modelica.Blocks.Math.Gain m_flow(k=-1/(cp*(50 - 30)))
    "Multiplier gain for calculating m_flow"
    annotation (Placement(transformation(extent={{-40,-28},{-20,-8}})));
  Fluid.MixingVolumes.MixingVolume           vol(
    redeclare package Medium = Medium_b,
    energyDynamics=energyDynamics,
    m_flow_nominal=mBui_flow_nominal,
    V=mBui_flow_nominal*tau/rho_default,
    nPorts=2) "Building volume"
    annotation (Placement(transformation(extent={{40,0},{60,20}})));
  HeatTransfer.Sources.PrescribedHeatFlow           heaFlo "Heat flow"
    annotation (Placement(transformation(extent={{10,0},{30,20}})));
  Modelica.Blocks.Sources.Constant TSetBuiSup(k=TBuiSupSet)
    "Building supply temperature"
    annotation (Placement(transformation(extent={{-80,-60},{-60,-40}})));
  Modelica.Blocks.Math.Gain heaGai(k=-1)
    "Multiplier for calculating heat gain of the volume"
    annotation (Placement(transformation(extent={{-30,0},{-10,20}})));
equation
  connect(QHea.y[1], pro.u1) annotation (Line(points={{-59,70},{-50,70},{-50,56},
          {-42,56}}, color={0,0,127}));
  connect(ram.y, pro.u2) annotation (Line(points={{-59,30},{-50,30},{-50,44},{
          -42,44}}, color={0,0,127}));
  connect(pum.port_b,vol. ports[1]) annotation (Line(points={{-2,-38},{-10,-38},
          {-10,0},{48,0}},    color={0,127,255}));
  connect(m_flow.y,pum. m_flow_in) annotation (Line(points={{-19,-18},{8,-18},{8,
          -26}},                                                                        color={0,0,127}));
  connect(pro.y, m_flow.u) annotation (Line(points={{-19,50},{-4,50},{-4,30},{-42,
          30},{-42,-18}}, color={0,0,127}));
  connect(TSetBuiSup.y, ets.TSetBuiSup) annotation (Line(points={{-59,-50},{30,-50},
          {30,-30},{38,-30}}, color={0,0,127}));
  connect(port_a, ets.port_a1) annotation (Line(points={{100,-60},{26,-60},{26,-24},
          {40,-24}}, color={0,127,255}));
  connect(ets.port_b1, port_b) annotation (Line(points={{60,-24},{80,-24},{80,0},
          {100,0}}, color={0,127,255}));
  connect(ets.port_b2, pum.port_a) annotation (Line(points={{40,-36},{38,-36},{38,
          -38},{18,-38}}, color={0,127,255}));
  connect(vol.ports[2], ets.port_a2) annotation (Line(points={{52,0},{70,0},{70,
          -36},{60,-36}}, color={0,127,255}));

protected
  parameter Modelica.SIunits.SpecificHeatCapacity cp=
   Medium_b.specificHeatCapacityCp(
      Medium_b.setState_pTX(Medium_b.p_default, Medium_b.T_default, Medium_b.X_default))
    "Default specific heat capacity of medium";
  parameter Medium_b.ThermodynamicState sta_default=Medium_b.setState_pTX(
      T=Medium_b.T_default, p=Medium_b.p_default, X=Medium_b.X_default);
  parameter Modelica.SIunits.Density rho_default=Medium_b.density(sta_default)
    "Density, used to compute fluid volume";


equation
  connect(heaFlo.port, vol.heatPort)
    annotation (Line(points={{30,10},{40,10}}, color={191,0,0}));
  connect(heaGai.y, heaFlo.Q_flow)
    annotation (Line(points={{-9,10},{10,10}}, color={0,0,127}));
  connect(pro.y, heaGai.u) annotation (Line(points={{-19,50},{-4,50},{-4,30},{
          -42,30},{-42,10},{-32,10}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Polygon(
          points={{20,-70},{60,-85},{20,-100},{20,-70}},
          lineColor={0,128,255},
          fillColor={0,128,255},
          fillPattern=FillPattern.Solid,
          visible=not allowFlowReversal),
        Line(
          points={{55,-85},{-60,-85}},
          color={0,128,255},
          visible=not allowFlowReversal),
                                Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Polygon(
        points={{0,80},{-78,38},{80,38},{0,80}},
        lineColor={95,95,95},
        smooth=Smooth.None,
        fillPattern=FillPattern.Solid,
        fillColor={95,95,95}),
      Rectangle(
          extent={{-64,38},{64,-70}},
          lineColor={150,150,150},
          fillPattern=FillPattern.Sphere,
          fillColor={255,0,0}),
      Rectangle(
        extent={{-42,-4},{-14,24}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{16,-4},{44,24}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{16,-54},{44,-26}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{-42,-54},{-14,-26}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Text(
          extent={{-149,-114},{151,-154}},
          lineColor={0,0,255},
          textString="%name")}), Diagram(coordinateSystem(preserveAspectRatio=false)));
end BuildingTimeSeriesHeating;
