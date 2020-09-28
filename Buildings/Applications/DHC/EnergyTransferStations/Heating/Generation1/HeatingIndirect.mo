within Buildings.Applications.DHC.EnergyTransferStations.Heating.Generation1;
model HeatingIndirect
  "Heating energy transfer station with a shell-and-tube heat exchanger"
  extends Buildings.Fluid.Interfaces.PartialFourPortFourMedium(
    final m2_flow_nominal=mBui_flow_nominal,
    final m1_flow_nominal=mDis_flow_nominal,
    redeclare final package Medium_b2 = Medium,
    redeclare final package Medium_a2 = Medium,
    redeclare final package Medium_b1 = Medium,
    redeclare final package Medium_a1 = MediumSat,
    show_T=true);

  replaceable package Medium =
      Modelica.Media.Interfaces.PartialMedium
    "Medium model (liquid state) for all other ports";
  replaceable package MediumSat =
      IBPSA.Media.Interfaces.PartialPureSubstanceWithSat
    "Medium model (vapor state) for port_a1 (primary inlet)";

  // Nominal conditions
  parameter Modelica.SIunits.MassFlowRate mDis_flow_nominal(
    final min=0,
    final start=0.5)
    "Nominal mass flow rate of primary (district) district cooling side";
  parameter Modelica.SIunits.MassFlowRate mBui_flow_nominal(
    final min=0,
    final start=0.5)
    "Nominal mass flow rate of secondary (building) district cooling side";
  parameter Modelica.SIunits.AbsolutePressure pSte_nominal
    "Nominal steam pressure";
  parameter Modelica.SIunits.PressureDifference dpValve_nominal(
    final min=0,
    final displayUnit="Pa")=6000
    "Nominal pressure drop of fully open control valve";
  parameter Modelica.SIunits.Density rhoStdCon = MediumSat.density(
    MediumSat.setState_pTX(
      pSte_nominal,
      MediumSat.saturationTemperature_p(pSte_nominal),
      MediumSat.X_default))
    "Condensate standard density";

// Controller
  // Controller parameters
  parameter Modelica.Blocks.Types.SimpleController controllerType=
    Modelica.Blocks.Types.SimpleController.PI
    "Type of controller"
    annotation(Dialog(tab="Controller"));
  parameter Real k(final min=0, final unit="1") = 1
    "Gain of controller"
    annotation(Dialog(tab="Controller"));
  parameter Modelica.SIunits.Time Ti(
    min=Modelica.Constants.small)=120
    "Time constant of integrator block"
     annotation (Dialog(tab="Controller", enable=
          controllerType == Modelica.Blocks.Types.SimpleController.PI or
          controllerType == Modelica.Blocks.Types.SimpleController.PID));
  parameter Modelica.SIunits.Time Td(final min=0)=0.1
    "Time constant of derivative block"
     annotation (Dialog(tab="Controller", enable=
          controllerType == Modelica.Blocks.Types.SimpleController.PD or
          controllerType == Modelica.Blocks.Types.SimpleController.PID));
  parameter Real wp(final min=0) = 1
   "Set-point weight for Proportional block (0..1)"
    annotation(Dialog(tab="Controller"));
  parameter Real wd(final min=0) = 0
   "Set-point weight for Derivative block (0..1)"
    annotation(Dialog(tab="Controller", enable=
          controllerType==Modelica.Blocks.Types.SimpleController.PD or
          controllerType==Modelica.Blocks.Types.SimpleController.PID));
  parameter Real Ni(min=100*Modelica.Constants.eps) = 0.9
    "Ni*Ti is time constant of anti-windup compensation"
    annotation(Dialog(tab="Controller", enable=
          controllerType==Modelica.Blocks.Types.SimpleController.PI or
          controllerType==Modelica.Blocks.Types.SimpleController.PID));
  parameter Real Nd(min=100*Modelica.Constants.eps) = 10
    "The higher Nd, the more ideal the derivative block"
    annotation(Dialog(tab="Controller", enable=
          controllerType==Modelica.Blocks.Types.SimpleController.PD or
          controllerType==Modelica.Blocks.Types.SimpleController.PID));
  parameter Modelica.Blocks.Types.InitPID initType=
    Modelica.Blocks.Types.InitPID.DoNotUse_InitialIntegratorState
    "Type of initialization (1: no init, 2: steady state, 3: initial state, 4: initial output)"
    annotation(Evaluate=true, Dialog(group="Initialization", tab="Controller"));
  parameter Real xi_start=0
    "Initial or guess value value for integrator output (= integrator state)"
    annotation (Dialog(group="Initialization", tab="Controller",
                       enable=controllerType==Modelica.Blocks.Types.SimpleController.PI or
                              controllerType==Modelica.Blocks.Types.SimpleController.PID));
  parameter Real xd_start=0
    "Initial or guess value for state of derivative block"
    annotation (Dialog(group="Initialization", tab="Controller",
                       enable=controllerType==Modelica.Blocks.Types.SimpleController.PD or
                              controllerType==Modelica.Blocks.Types.SimpleController.PID));
  parameter Real yCon_start=0
    "Initial value of output from the controller"
    annotation(Dialog(group="Initialization", tab="Controller",
                      enable=initType == Modelica.Blocks.Types.InitPID.InitialOutput));
  parameter Boolean reverseAction = true
    "Set to true for throttling the water flow rate through a cooling coil controller"
    annotation(Dialog(tab="Controller"));

//  parameter Modelica.SIunits.SpecificEnthalpy dh_nominal(
//    min=0) "Nominal change in enthalpy";

//  parameter Modelica.SIunits.MassFlowRate m_flow_nominal = Q_flow_nominal/dh_nominal
//    "Nominal mass flow rate";


//protected
  Buildings.Fluid.HeatExchangers.SteamConstantEffectiveness hex(
    final m1_flow_nominal=mDis_flow_nominal,
    final m2_flow_nominal=mBui_flow_nominal,
    show_T=true,
    redeclare package Medium = Medium,
    redeclare package MediumSat = MediumSat,
    pSte_nominal=pSte_nominal)
    annotation (Placement(transformation(extent={{20,-20},{40,0}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort temSen(
    redeclare package Medium = Medium,
    final m_flow_nominal=mBui_flow_nominal)
    "Temperature sensor"
    annotation (Placement(transformation(extent={{-40,-70},{-60,-50}})));
  Buildings.Controls.Continuous.LimPID con(
    final controllerType=controllerType,
    final Ti=Ti,
    final k=k,
    final Td=Td,
    final yMax=1,
    final yMin=0,
    final wp=wp,
    final wd=wd,
    final Ni=Ni,
    final Nd=Nd,
    final initType=initType,
    final xi_start=xi_start,
    final reverseActing=reverseAction)
    "Controller"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Fluid.Actuators.Valves.TwoWayEqualPercentage val(
    redeclare package Medium = MediumSat,
    rhoStd=rhoStdCon,
    l=0.005,
    final m_flow_nominal=mDis_flow_nominal,
    dpFixed_nominal=2000 + 3000,
    dpValve_nominal=6000) "Valve"
    annotation (Placement(transformation(extent={{-40,70},{-20,50}})));
  Modelica.Blocks.Interfaces.RealInput TSetBuiSup(
    final quantity="ThermodynamicTemperature",
    final unit="K")
    "Setpoint temperature for building supply"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
equation
  connect(TSetBuiSup, con.u_s)
    annotation (Line(points={{-120,0},{-62,0}}, color={0,0,127}));
  connect(con.y, val.y)
    annotation (Line(points={{-39,0},{-30,0},{-30,48}}, color={0,0,127}));
  connect(val.port_b, hex.port_a1) annotation (Line(points={{-20,60},{10,60},{10,
          -4},{20,-4}}, color={0,127,255}));
  connect(hex.port_b1, port_b1) annotation (Line(points={{40,-4},{50,-4},{50,60},
          {100,60}}, color={0,127,255}));
  connect(port_b2, temSen.port_b)
    annotation (Line(points={{-100,-60},{-60,-60}}, color={0,127,255}));
  connect(temSen.T, con.u_m)
    annotation (Line(points={{-50,-49},{-50,-12}}, color={0,0,127}));
  connect(temSen.port_a, hex.port_b2) annotation (Line(points={{-40,-60},{10,-60},
          {10,-16},{20,-16}}, color={0,127,255}));
  connect(hex.port_a2, port_a2) annotation (Line(points={{40,-16},{50,-16},{50,-60},
          {100,-60}}, color={0,127,255}));
  connect(val.port_a, port_a1) annotation (Line(points={{-40,60},{-70,60},{-70,60},
          {-100,60}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-80,92},{80,-90}},
          lineColor={0,0,0},
          fillColor={200,200,200},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-149,-114},{151,-154}},
          lineColor={0,0,255},
          textString="%name"),
        Rectangle(
          extent={{-36,74},{36,-72}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.VerticalCylinder),
        Ellipse(
          extent={{-36,62},{36,86}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.Sphere),
        Rectangle(
          extent={{-22,50},{-14,-64}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,-56},{-14,-64}},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          lineColor={0,0,0}),
        Ellipse(
          extent={{-22,40},{22,58}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{14,50},{22,-62}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{14,-56},{100,-64}},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          lineColor={0,0,0}),
        Ellipse(
          extent={{-14,34},{14,50}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-102,64},{-36,56}},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{36,-26},{96,-34}},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{96,62},{104,-34}},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{36,-24},{50,-36}},
          fillColor={238,46,47},
          fillPattern=FillPattern.HorizontalCylinder,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{-50,66},{-36,54}},
          fillColor={238,46,47},
          fillPattern=FillPattern.HorizontalCylinder,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(extent={{-50,66},{-36,54}}, lineColor={0,0,0}),
        Rectangle(extent={{36,-24},{50,-36}}, lineColor={0,0,0})}),
                                                                 Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end HeatingIndirect;
