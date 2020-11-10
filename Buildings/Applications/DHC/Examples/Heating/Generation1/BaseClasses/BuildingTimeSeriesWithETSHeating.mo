within Buildings.Applications.DHC.Examples.Heating.Generation1.BaseClasses;
model BuildingTimeSeriesWithETSHeating
  "Model of a building with thermal loads as time series, with an energy transfer station"
  extends Buildings.Fluid.Interfaces.PartialTwoPortTwoMedium(
    redeclare final package Medium_b = MediumWat,
    redeclare final package Medium_a = MediumSte,
    final m_flow_nominal=mDis_flow_nominal);

  replaceable package MediumSte =
      IBPSA.Media.Interfaces.PartialPureSubstanceWithSat
    "Medium model (vapor state) for port_a (inlet)";
  replaceable package MediumWat =
      Modelica.Media.Interfaces.PartialMedium
    "Medium model (liquid state) for port_b (outlet)";

  parameter Boolean allowFlowReversalBui = false
    "Set to true to allow flow reversal on the building side"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Boolean allowFlowReversalDis = false
    "Set to true to allow flow reversal on the district side"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Modelica.SIunits.Time perAve = 600
    "Period for time averaged variables";

  // building parameters
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation(Evaluate=true, Dialog(tab = "Dynamics", group="Equations"));
  parameter String filNam
    "Library path of the file with thermal loads as time series"
    annotation (Dialog(group="Building"));
  final parameter Modelica.SIunits.Power Q_flow_nominal=
    Buildings.Experimental.DistrictHeatingCooling.SubStations.VaporCompression.BaseClasses.getPeakLoad(
    string="#Peak space heating load",
    filNam=Modelica.Utilities.Files.loadResource(filNam))
    "Design heating flow rate (>=0)Nominal heat flow rate, positive";
  parameter Modelica.SIunits.Temperature THotWatSup_nominal=273.15 + 60
    "Nominal temperature for hot water supply"
    annotation (Dialog(group="Building"));
  parameter Modelica.SIunits.Temperature TWatRet_nominal=273.15 + 38
    "Nominal temperature for water return"
    annotation (Dialog(group="Building"));

  // ETS parameters
  parameter Modelica.SIunits.AbsolutePressure pSte_nominal=150000
    "Nominal pressure for district steam supply"
    annotation (Dialog(group="Energy transfer station"));
  parameter Modelica.SIunits.Temperature TSteSup_nominal=
    Medium_a.saturationTemperature_p(pSte_nominal)
    "Setpoint temperature for district steam supply"
    annotation (Dialog(group="Energy transfer station"));
  parameter Modelica.SIunits.Temperature TConRet_nominal=273.15 + 120
    "Setpoint temperature for district condensate return"
    annotation (Dialog(group="Energy transfer station"));
  parameter Modelica.SIunits.Temperature TSetHotWat=THotWatSup_nominal
    "Setpoint temperature for building supply"
    annotation (Dialog(group="Energy transfer station"));
  parameter Modelica.SIunits.MassFlowRate mDis_flow_nominal(
    final min=0,
    final start=0.5)
    "Nominal mass flow rate of district cooling side"
    annotation (Dialog(group="Energy transfer station"));
  parameter Modelica.SIunits.MassFlowRate mBui_flow_nominal(
    final min=0,
    final start=0.5)=Q_flow_nominal/(cp*(THotWatSup_nominal - TWatRet_nominal))
    "Nominal mass flow rate of building heating side"
    annotation (Dialog(group="Energy transfer station"));

  // IO CONNECTORS

  // COMPONENTS
  replaceable DHC.Loads.Examples.BaseClasses.BuildingTimeSeries bui(
    have_watHea=true,
    have_watCoo=false,
    T_aHeaWat_nominal=THotWatSup_nominal,
    T_bHeaWat_nominal=TWatRet_nominal,
    mLoaHea_flow_nominal=2,
    loa(
      columns={2,3},
      timeScale(displayUnit="h") = 3600,
      offset={0,0}),
    final energyDynamics=energyDynamics,
    final use_inputFilter=false,
    final filNam=filNam,
    final allowFlowReversal=allowFlowReversalBui,
    nPorts_aHeaWat=1,
    nPorts_bHeaWat=1)
    "Building"
    annotation (Placement(transformation(extent={{-10,40},{10,60}})));
  replaceable
    Buildings.Applications.DHC.EnergyTransferStations.Heating.Generation1.HeatingIndirect
    ets(
    redeclare package Medium = MediumWat,
    redeclare package MediumSat = MediumSte,
    mDis_flow_nominal=mDis_flow_nominal,
    mBui_flow_nominal=mBui_flow_nominal,
    pSte_nominal=pSte_nominal)
        annotation (Placement(transformation(extent={{-10,-40},{10,-20}})));
  inner Modelica.Fluid.System system
    "System properties and default values"
    annotation (Placement(transformation(extent={{-80,40},{-60,60}})));

  Modelica.Blocks.Sources.Constant TSetBuiSup(k=TSetHotWat)
    "Building supply temperature setpoint"
    annotation (Placement(transformation(extent={{-80,-40},{-60,-20}})));
  Fluid.Sources.Boundary_pT pRef(redeclare package Medium = MediumWat, nPorts=1)
    "Reference pressure"
    annotation (Placement(transformation(extent={{60,20},{40,40}})));
protected
  parameter Modelica.SIunits.SpecificHeatCapacity cp=
   Medium_b.specificHeatCapacityCp(
      Medium_b.setState_pTX(Medium_b.p_default, Medium_b.T_default, Medium_b.X_default))
    "Default specific heat capacity of Medium_b";

equation
  connect(port_a, ets.port_a1) annotation (Line(points={{-100,0},{-20,0},{-20,
          -24},{-10,-24}}, color={0,127,255}));
  connect(ets.port_b1, port_b) annotation (Line(points={{10,-24},{20,-24},{20,0},
          {100,0}}, color={0,127,255}));
  connect(TSetBuiSup.y, ets.TSetBuiSup)
    annotation (Line(points={{-59,-30},{-12,-30}}, color={0,0,127}));
  connect(ets.port_b2, bui.ports_aHeaWat[1]) annotation (Line(points={{-10,-36},
          {-30,-36},{-30,48},{-10,48},{-10,48}}, color={0,127,255}));
  connect(bui.ports_bHeaWat[1], ets.port_a2) annotation (Line(points={{10,48},{
          30,48},{30,-36},{10,-36}}, color={0,127,255}));
  connect(pRef.ports[1], ets.port_a2) annotation (Line(points={{40,30},{30,30},
          {30,-36},{10,-36}}, color={0,127,255}));
  annotation (Line(
      points={{-1,100},{0.1,100},{0.1,71.4}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}}),
         graphics={
        Rectangle(
          extent={{-60,-34},{0,-40}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(extent={{-100,100},{100,-100}}, lineColor={0,0,0}),
        Rectangle(
          extent={{-60,-34},{0,-28}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{0,-40},{60,-34}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{0,-28},{60,-34}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{60,6},{100,0}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,0},{-60,-6}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,0},{-60,6}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{60,-6},{100,0}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
      Polygon(
        points={{0,80},{-40,60},{40,60},{0,80}},
        lineColor={95,95,95},
        smooth=Smooth.None,
        fillPattern=FillPattern.Solid,
        fillColor={95,95,95}),
      Rectangle(
          extent={{-40,60},{40,-40}},
          lineColor={150,150,150},
          fillPattern=FillPattern.Sphere,
          fillColor={255,255,255}),
      Rectangle(
        extent={{-30,30},{-10,50}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{10,30},{30,50}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{-30,-10},{-10,10}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{10,-10},{30,10}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-20,-3},{20,3}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid,
          origin={63,-20},
          rotation=90),
        Rectangle(
          extent={{-19,3},{19,-3}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid,
          origin={-63,-21},
          rotation=90),
        Rectangle(
          extent={{-19,-3},{19,3}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid,
          origin={-57,-13},
          rotation=90),
        Rectangle(
          extent={{-19,3},{19,-3}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid,
          origin={57,-13},
          rotation=90),
        Text(
          extent={{-149,-114},{151,-154}},
          lineColor={0,0,255},
          textString="%name")}),
    experiment(StopTime=86400));
end BuildingTimeSeriesWithETSHeating;
