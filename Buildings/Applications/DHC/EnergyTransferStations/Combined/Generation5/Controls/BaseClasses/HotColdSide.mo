within Buildings.Applications.DHC.EnergyTransferStations.Combined.Generation5.Controls.BaseClasses;
partial block HotColdSide "State machine enabling production and ambient source systems"
  extends Modelica.Blocks.Icons.Block;

  parameter Integer nCon = 1
    "Number of controllers in sequence for ambient sources"
    annotation(Evaluate=true);
  parameter Modelica.SIunits.TemperatureDifference dTHys = 1
    "Temperature hysteresis (full width, absolute value)";
  parameter Modelica.SIunits.TemperatureDifference dTDea = 1
    "Temperature dead band (absolute value)";
  parameter Boolean reverseActing = false
    "Set to true for control output decreasing with measurement value";

  parameter Buildings.Controls.OBC.CDL.Types.SimpleController controllerType[nCon]=
    fill(Buildings.Controls.OBC.CDL.Types.SimpleController.P, nCon)
    "Type of controller"
    annotation(choices(
      choice=Buildings.Controls.OBC.CDL.Types.SimpleController.P,
      choice=Buildings.Controls.OBC.CDL.Types.SimpleController.PI));
  parameter Real k[nCon](each min=0) = fill(1, nCon)
    "Gain of controller";
  parameter Modelica.SIunits.Time Ti[nCon](
    each min=Buildings.Controls.OBC.CDL.Constants.small) = fill(0.5, nCon)
    "Time constant of integrator block"
    annotation (Dialog(enable=Modelica.Math.BooleanVectors.anyTrue({
      controllerType[i] == Buildings.Controls.OBC.CDL.Types.SimpleController.PI or
      controllerType[i] == Buildings.Controls.OBC.CDL.Types.SimpleController.PID
      for i in 1:nCon})));

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSet(
    final unit="K",
    displayUnit="degC")
    "Supply temperature set-point (heating or chilled water)"
    annotation (Placement(transformation(extent={{-220,100},{-180,140}}),
      iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TTop(
    final unit="K",
    displayUnit="degC")
    "Temperature at top of tank"
    annotation (Placement(transformation(extent={{-220,-120},{-180,-80}}),
      iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TBot(
    final unit="K",
    displayUnit="degC")
    "Temperature at bottom of tank"
    annotation (Placement(transformation(extent={{-220,-180},{-180,-140}}),
      iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yIsoAmb(unit="1")
    "Ambient loop isolation valve control signal"
    annotation (Placement(
      transformation(extent={{180,-160},{220,-120}}),
      iconTransformation(
        extent={{100,-80},{140,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput y[nCon](unit="1")
    "Control output for ambient sources"
    annotation (Placement(transformation(
          extent={{180,-20},{220,20}}), iconTransformation(extent={{100,-20},{140,
            20}})));

  inner Modelica.StateGraph.StateGraphRoot stateGraphRoot
    annotation (Placement(transformation(extent={{-60,140},{-40,160}})));
  Modelica.StateGraph.InitialStep noDemand(nIn=2)
    "State if no heat or heat rejection is required"
    annotation (Placement(transformation(extent={{0,130},{20,150}})));
  Modelica.StateGraph.TransitionWithSignal t1(enableTimer=true, waitTime=60)
    annotation (Placement(transformation(extent={{50,130},{70,150}})));
  Modelica.StateGraph.StepWithSignal run
    "On/off command of heating or cooling system"
    annotation (Placement(transformation(extent={{80,130},{100,150}})));
  Modelica.StateGraph.TransitionWithSignal t2
    annotation (Placement(transformation(extent={{110,130},{130,150}})));
  Buildings.Controls.OBC.CDL.Continuous.GreaterEqual enaHeaCoo
    "Threshold comparison for enabling heating or cooling system"
    annotation (Placement(transformation(extent={{18,30},{38,50}})));
  Buildings.Controls.OBC.CDL.Continuous.GreaterEqual disHeaCoo
    "Threshold comparison for disabling heating or cooling system"
    annotation (Placement(transformation(extent={{18,-10},{38,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yHeaCoo
    "Enabled signal for heating or cooling system"
    annotation (Placement(transformation(extent={{180,80},{220,120}}),
      iconTransformation(extent={{100,40},{140,80}})));
  LimPlaySequence conPlaSeq(
    final nCon=nCon,
    final hys=fill(dTHys, nCon),
    final dea=fill(dTDea, nCon),
    final yMin=fill(0, nCon),
    final yMax=fill(1, nCon),
    final controllerType=controllerType,
    final k=k,
    final Ti=Ti,
    final reverseActing=reverseActing)
    annotation (Placement(transformation(extent={{-90,-150},{-70,-130}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiMax mulMax(
    final nin=nCon)
    annotation (Placement(transformation(extent={{-10,-150},{10,-130}})));
  Buildings.Controls.OBC.CDL.Continuous.GreaterThreshold greThr
    annotation (Placement(transformation(extent={{60,-150},{80,-130}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea
    annotation (Placement(transformation(extent={{120,-150},{140,-130}})));
  Buildings.Controls.OBC.CDL.Continuous.Feedback errEna "Error for enabling"
    annotation (Placement(transformation(extent={{-110,30},{-90,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Feedback errDis "Disabling error"
    annotation (Placement(transformation(extent={{-90,-10},{-70,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer(k=0) "Zero"
    annotation (Placement(transformation(extent={{-40,-50},{-20,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Product proEna
    "Opposite if reverse acting"
    annotation (Placement(transformation(extent={{-40,30},{-20,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Product proDis
    "Opposite if reverse acting"
    annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant revAct(
    final k= reverseActing) "Output true in case of reverse acting"
    annotation (Placement(transformation(extent={{-120,70},{-100,90}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea1(
    final realTrue=-1,
    final realFalse=1)
    annotation (Placement(transformation(extent={{-90,70},{-70,90}})));
initial equation
  assert(dTHys >= 0, "In " + getInstanceName() +
    ": dTHys (" + String(dTHys) + ") must be an absolute value.");
  assert(dTDea >= 0, "In " + getInstanceName() +
    ": dTDea (" + String(dTDea) + ") must be an absolute value.");
equation
  connect(t1.outPort, run.inPort[1])
    annotation (Line(points={{61.5,140},{79,140}},   color={0,0,0}));
  connect(run.outPort[1], t2.inPort)
    annotation (Line(points={{100.5,140},{116,140}},color={0,0,0}));
  connect(enaHeaCoo.y, t1.condition) annotation (Line(points={{40,40},{60,40},{60,
          128}}, color={255,0,255}));
  connect(disHeaCoo.y, t2.condition)
    annotation (Line(points={{40,0},{120,0},{120,128}}, color={255,0,255}));
  connect(run.active, yHeaCoo) annotation (Line(points={{90,129},{90,100},{200,100}},
                 color={255,0,255}));
  connect(conPlaSeq.y, mulMax.u[1:1])
    annotation (Line(points={{-68,-140},{-12,-140}}, color={0,0,127}));
  connect(mulMax.y, greThr.u)
    annotation (Line(points={{12,-140},{58,-140}}, color={0,0,127}));
  connect(greThr.y, booToRea.u) annotation (Line(points={{82,-140},{118,-140}},
                     color={255,0,255}));
  connect(booToRea.y, yIsoAmb) annotation (Line(points={{142,-140},{200,-140}},
                           color={0,0,127}));
  connect(TSet, errEna.u1) annotation (Line(points={{-200,120},{-160,120},{-160,
          40},{-112,40}}, color={0,0,127}));
  connect(TSet, errDis.u1) annotation (Line(points={{-200,120},{-160,120},{-160,
          0},{-92,0}}, color={0,0,127}));
  connect(zer.y, disHeaCoo.u1) annotation (Line(points={{-18,-40},{8,-40},{8,0},
          {16,0}}, color={0,0,127}));
  connect(zer.y, enaHeaCoo.u2) annotation (Line(points={{-18,-40},{8,-40},{8,32},
          {16,32}}, color={0,0,127}));
  connect(proEna.y, enaHeaCoo.u1)
    annotation (Line(points={{-18,40},{16,40}},  color={0,0,127}));
  connect(proDis.y, disHeaCoo.u2) annotation (Line(points={{-18,0},{0,0},{0,-8},
          {16,-8}}, color={0,0,127}));
  connect(revAct.y, booToRea1.u)
    annotation (Line(points={{-98,80},{-92,80}}, color={255,0,255}));
  connect(errEna.y, proEna.u2) annotation (Line(points={{-88,40},{-80,40},{-80,34},
          {-42,34}}, color={0,0,127}));
  connect(errDis.y, proDis.u2) annotation (Line(points={{-68,0},{-60,0},{-60,-6},
          {-42,-6}}, color={0,0,127}));
  connect(booToRea1.y, proDis.u1) annotation (Line(points={{-68,80},{-60,80},{-60,
          6},{-42,6}}, color={0,0,127}));
  connect(booToRea1.y, proEna.u1) annotation (Line(points={{-68,80},{-60,80},{-60,
          46},{-42,46}}, color={0,0,127}));
  connect(noDemand.outPort[1], t1.inPort)
    annotation (Line(points={{20.5,140},{56,140}},  color={0,0,0}));
  connect(t2.outPort, noDemand.inPort[1]) annotation (Line(points={{121.5,140},{
          140,140},{140,180},{-20,180},{-20,140},{-10,140},{-10,140.5},{-1,140.5}},
        color={0,0,0}));
  connect(conPlaSeq.y, y) annotation (Line(points={{-68,-140},{-40,-140},{-40,-100},
          {160,-100},{160,0},{200,0}}, color={0,0,127}));
  connect(TSet, conPlaSeq.u_s) annotation (Line(points={{-200,120},{-160,120},{-160,
          -140},{-92,-140}}, color={0,0,127}));
   annotation (
 Documentation(info="<html>


</html>", revisions="<html>
<ul>
<li>
November 25, 2019, by Hagar Elarga:<br/>
Added the info section.
</li>
<li>
March 21, 2019, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(extent={{-180,-200},{180,200}})));
end HotColdSide;