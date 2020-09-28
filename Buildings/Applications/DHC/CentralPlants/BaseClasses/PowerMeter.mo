within Buildings.Applications.DHC.CentralPlants.BaseClasses;
model PowerMeter

  parameter Modelica.SIunits.Time perAve = 600
    "Period for time averaged variables";

  Modelica.Blocks.Continuous.Integrator EHeaReq(y(unit="J"))
    "Time integral of heating load"
    annotation (Placement(transformation(extent={{40,40},{60,60}})));
  Modelica.Blocks.Continuous.Integrator EHeaAct(y(unit="J"))
    "Actual energy used for heating"
    annotation (Placement(transformation(extent={{40,80},{60,100}})));
  Buildings.Controls.OBC.CDL.Continuous.MovingMean QAveHeaReq_flow(y(unit="W"),
      final delta=perAve)
    "Time average of heating load"
    annotation (Placement(transformation(extent={{-20,40},{0,60}})));
  Buildings.Controls.OBC.CDL.Continuous.MovingMean QAveHeaAct_flow(y(unit="W"),
      final delta=perAve)
    "Time average of heating heat flow rate"
    annotation (Placement(transformation(extent={{-20,80},{0,100}})));
  Modelica.Blocks.Continuous.Integrator ECooReq(y(unit="J"))
    "Time integral of cooling load"
    annotation (Placement(transformation(extent={{40,-100},{60,-80}})));
  Modelica.Blocks.Continuous.Integrator ECooAct(y(unit="J"))
    "Actual energy used for cooling"
    annotation (Placement(transformation(extent={{40,-60},{60,-40}})));
  Buildings.Controls.OBC.CDL.Continuous.MovingMean QAveCooReq_flow(y(unit="W"),
      final delta=perAve)
    "Time average of cooling load"
    annotation (Placement(transformation(extent={{-20,-100},{0,-80}})));
  Buildings.Controls.OBC.CDL.Continuous.MovingMean QAveCooAct_flow(y(unit="W"),
      final delta=perAve)
    "Time average of cooling heat flow rate"
    annotation (Placement(transformation(extent={{-20,-60},{0,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput QHeaReq_flow
    annotation (Placement(transformation(extent={{-140,30},{-100,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput QCooReq_flow
    annotation (Placement(transformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput QCooAct_flow
    annotation (Placement(transformation(extent={{-140,-70},{-100,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput QHeaAct_flow
    annotation (Placement(transformation(extent={{-140,70},{-100,110}})));
  Modelica.Blocks.Interfaces.RealOutput PPum "Power drawn by pump motors"
    annotation (Placement(transformation(extent={{100,-10},{120,10}}),
        iconTransformation(extent={{100,-10},{120,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput PPumIn "Pump power"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
equation
  connect(QHeaReq_flow, QAveHeaReq_flow.u)
    annotation (Line(points={{-120,50},{-22,50}}, color={0,0,127}));
  connect(QHeaReq_flow, EHeaReq.u) annotation (Line(points={{-120,50},{-40,50},
          {-40,36},{30,36},{30,50},{38,50}},color={0,0,127}));
  connect(QHeaAct_flow, QAveHeaAct_flow.u)
    annotation (Line(points={{-120,90},{-22,90}}, color={0,0,127}));
  connect(QHeaAct_flow, EHeaAct.u) annotation (Line(points={{-120,90},{-40,90},
          {-40,76},{30,76},{30,90},{38,90}},color={0,0,127}));
  connect(QCooReq_flow, QAveCooReq_flow.u)
    annotation (Line(points={{-120,-90},{-22,-90}}, color={0,0,127}));
  connect(QCooReq_flow, ECooReq.u) annotation (Line(points={{-120,-90},{-40,-90},
          {-40,-70},{30,-70},{30,-90},{38,-90}}, color={0,0,127}));
  connect(QCooAct_flow, QAveCooAct_flow.u)
    annotation (Line(points={{-120,-50},{-22,-50}}, color={0,0,127}));
  connect(QCooAct_flow, ECooAct.u) annotation (Line(points={{-120,-50},{-40,-50},
          {-40,-30},{30,-30},{30,-50},{38,-50}}, color={0,0,127}));
  connect(PPumIn, PPum)
    annotation (Line(points={{-120,0},{110,0},{110,0}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
          Rectangle(
          extent={{-80,-82},{80,80}},
          lineColor={0,0,0},
          fillColor={211,211,211},
          fillPattern=FillPattern.Solid), Text(
          extent={{-60,-60},{60,60}},
          lineColor={0,0,0},
          fillColor={211,211,211},
          fillPattern=FillPattern.None,
          textString="M")}), Diagram(coordinateSystem(preserveAspectRatio=false)));
end PowerMeter;
