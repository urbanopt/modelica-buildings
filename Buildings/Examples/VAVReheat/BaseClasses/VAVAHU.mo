within Buildings.Examples.VAVReheat.BaseClasses;
model VAVAHU "VAV air handler unit"
  package MediumAir = Buildings.Media.Air "Medium model for air";
  package MediumWat = Buildings.Media.Water "Medium model for water";

  parameter Modelica.SIunits.MassFlowRate mAir_flow_nominal "Nominal air mass flow rate";
  parameter Modelica.SIunits.MassFlowRate mWatCooCoi_flow_nominal "Nominal water mass flow rate for cooling coil";
  parameter Modelica.SIunits.MassFlowRate mWatHeaCoi_flow_nominal "Nominal water mass flow rate for heating coil";

  parameter Modelica.SIunits.HeatFlowRate Q_flow_nominal
    "Nominal heat transfer of heating coil";
  parameter Modelica.SIunits.Temperature THeaCoiWatIn_nominal=318.15
    "Nominal water inlet temperature heating coil";
  parameter Modelica.SIunits.Temperature THeaCoiAirIn_nominal=281.65
    "Nominal air inlet temperature heating coil";

  parameter Modelica.SIunits.PressureDifference dpHeaCoiWat_nominal=3000
    "Water-side pressure drop of heating coil";

  parameter Modelica.SIunits.PressureDifference dpCooCoiWat_nominal=3000
    "Water-side pressure drop of cooling coil";

  parameter Modelica.SIunits.PressureDifference dpSup_nominal=500
    "Pressure difference of supply air leg (coils and filter)";

  parameter Modelica.SIunits.PressureDifference dpRet_nominal=50
    "Pressure difference of supply air leg (coils and filter)";

  parameter Modelica.SIunits.PressureDifference dpFanSup_nominal(min=Modelica.Constants.small)
    "Fan head at mAir_flow_nominal and full speed";

  parameter Fluid.Movers.Data.Generic datFanSup(
    pressure(
      V_flow={0,mAir_flow_nominal/1.2*2},
      dp=2*{dpFanSup_nominal,0}))
    "Performance data for supply fan"
    annotation (Placement(transformation(extent={{260,320},{280,340}})));

  Buildings.Controls.OBC.CDL.Interfaces.RealInput yFanSup(
     final unit="1",
     min=0,
     max=1)
     "Fan control signal" annotation (Placement(transformation(extent={
            {-440,340},{-400,380}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput yEcoRet(
     final unit="1",
     min=0,
     max=1)
    "Economizer return damper position (0: closed, 1: open)" annotation (Placement(
        transformation(extent={{-440,220},{-400,260}}), iconTransformation(
          extent={{-440,220},{-400,260}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput yEcoOut(
     final unit="1",
     min=0,
     max=1)
    "Economizer outdoor air damper signal (0: closed, 1: open)" annotation (Placement(
        transformation(extent={{-440,260},{-400,300}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput yEcoExh(
     final unit="1",
     min=0,
     max=1)
    "Econoizer exhaust air damper signal (0: closed, 1: open)"
    annotation (Placement(transformation(extent={{-440,300},{-400,340}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TAirMix(
    final unit="K",
    displayUnit="degC") "Mixed air temperture"
    annotation (Placement(transformation(extent={{400,350},{420,370}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TAirSup(
    final unit="K",
    displayUnit="degC")
    "Temperature of the passing fluid"
    annotation (Placement(transformation(extent={{400,310},{420,330}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TAirRet(
    final unit="K",
    displayUnit="degC") "Return air temperature"
    annotation (Placement(transformation(extent={{400,270},{420,290}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput VOut_flow(
    final unit="m3/s") "Outdoor air flow rate"
    annotation (Placement(transformation(extent={{400,230},{420,250}})));


  Modelica.Fluid.Interfaces.FluidPort_a port_freAir(redeclare package Medium =
        MediumAir) "Fresh air intake" annotation (Placement(transformation(
          extent={{-410,30},{-390,50}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_exhAir(redeclare package Medium =
        MediumAir) "Exhaust air" annotation (Placement(transformation(extent={{-410,
            -50},{-390,-30}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_supAir(redeclare package Medium =
        MediumAir) "Supply air" annotation (Placement(transformation(extent={{390,-50},
            {410,-30}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_retAir(redeclare package Medium =
        MediumAir) "Return air"
    annotation (Placement(transformation(extent={{392,30},{412,50}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_cooCoiIn(redeclare package Medium =
        MediumWat) "Cooling coil inlet"
    annotation (Placement(transformation(extent={{110,-410},{130,-390}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_CooCoiOut(redeclare package Medium =
        MediumWat) "Cooling coil outlet" annotation (Placement(transformation(
          extent={{30,-410},{50,-390}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_heaCoiIn(redeclare package Medium =
        MediumWat) "Heating coil inlet"
    annotation (Placement(transformation(extent={{-50,-410},{-30,-390}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_heaCoiOut(redeclare package Medium =
        MediumWat) "Heating coil outlet"
    annotation (Placement(transformation(extent={{-130,-410},{-110,-390}})));

  Fluid.HeatExchangers.DryCoilEffectivenessNTU heaCoi(
    redeclare package Medium1 = MediumWat,
    redeclare package Medium2 = MediumAir,
    m1_flow_nominal=mWatHeaCoi_flow_nominal,
    m2_flow_nominal=mAir_flow_nominal,
    configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
    use_Q_flow_nominal=true,
    Q_flow_nominal=Q_flow_nominal,
    dp1_nominal=dpHeaCoiWat_nominal,
    dp2_nominal=0,
    T_a1_nominal=THeaCoiWatIn_nominal,
    T_a2_nominal=THeaCoiAirIn_nominal)
    "Heating coil"
    annotation (Placement(transformation(extent={{20,-36},{0,-56}})));

  Fluid.HeatExchangers.WetCoilCounterFlow cooCoi(
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumA,
    UA_nominal=3*m_flow_nominal*1000*15/
        Buildings.Fluid.HeatExchangers.BaseClasses.lmtd(
        T_a1=26.2,
        T_b1=12.8,
        T_a2=6,
        T_b2=16),
    m1_flow_nominal=mWatCooCoi_flow_nominal,
    m2_flow_nominal=mAir_flow_nominal,
    dp1_nominal=dpCooCoiWat_nominal,
    dp2_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Cooling coil"
    annotation (Placement(transformation(extent={{82,-36},{62,-56}})));

  Fluid.FixedResistances.PressureDrop resSup(
    redeclare package Medium = MediumAir,
    m_flow_nominal=mAir_flow_nominal,
    dp_nominal=dpSup_nominal)
    "Pressure drop of heat exchangers and filter combined"
    annotation (Placement(transformation(extent={{140,-50},{160,-30}})));

  Fluid.Sensors.TemperatureTwoPort senTMix(
    redeclare package Medium = MediumAir,
    m_flow_nominal=mAir_flow_nominal) "Mixed air temperature sensor"
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));

  MixingBox eco(
    redeclare package Medium = MediumAir,
    mOut_flow_nominal=mAir_flow_nominal,
    dpOut_nominal=10,
    mRec_flow_nominal=mAir_flow_nominal,
    dpRec_nominal=10,
    mExh_flow_nominal=mAir_flow_nominal,
    dpExh_nominal=10,
    from_dp=false) "Economizer" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-90,2})));
  Fluid.Sensors.TemperatureTwoPort TRet(
    redeclare package Medium = MediumAir,
    m_flow_nominal=mAir_flow_nominal) "Return air temperature sensor"
    annotation (Placement(transformation(extent={{360,30},{340,50}})));
  Fluid.FixedResistances.PressureDrop resRet(
    redeclare package Medium = MediumAir,
    m_flow_nominal=mAir_flow_nominal,
    dp_nominal=dpRet_nominal)
                  "Pressure drop for return duct"
    annotation (Placement(transformation(extent={{160,30},{140,50}})));
  Fluid.Movers.SpeedControlled_y fanSup(
    redeclare package Medium = MediumAir,
    per(pressure(V_flow={0,m_flow_nominal/1.2*2}, dp=2*{780 + 10 + dpBuiStaSet,0})),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial) "Supply air fan"
    annotation (Placement(transformation(extent={{220,-50},{240,-30}})));

  Fluid.Sensors.TemperatureTwoPort senTSup(
    redeclare package Medium = MediumAir,
    m_flow_nominal=mAir_flow_nominal) "Supply air temperature sensor"
    annotation (Placement(transformation(extent={{310,-50},{330,-30}})));
  Fluid.Sensors.VolumeFlowRate senVOut_flow(redeclare package Medium =
        MediumAir, m_flow_nominal=mAir_flow_nominal)
    "Outside air volume flow rate"
    annotation (Placement(transformation(extent={{-160,30},{-140,50}})));



equation
  connect(eco.port_Out, senVOut_flow.port_b) annotation (Line(points={{-100,8},{
          -120,8},{-120,40},{-140,40}}, color={0,127,255}));
  connect(eco.port_Ret, senTMix.port_a) annotation (Line(points={{-80,-4},{-68,-4},
          {-68,-40},{-60,-40}}, color={0,127,255}));
  connect(senTMix.port_b, heaCoi.port_a2)
    annotation (Line(points={{-40,-40},{0,-40}},   color={0,127,255}));
  connect(heaCoi.port_b2, cooCoi.port_a2)
    annotation (Line(points={{20,-40},{62,-40}},color={0,127,255}));
  connect(resSup.port_b, fanSup.port_a)
    annotation (Line(points={{160,-40},{220,-40}}, color={0,127,255}));
  connect(senVOut_flow.port_a, port_freAir) annotation (Line(points={{-160,40},{
          -400,40}},                     color={0,127,255}));
  connect(eco.port_Exh, port_exhAir) annotation (Line(points={{-100,-4},{-120,-4},
          {-120,-40},{-400,-40}}, color={0,127,255}));
  connect(senTSup.port_b, port_supAir)
    annotation (Line(points={{330,-40},{400,-40}}, color={0,127,255}));
  connect(TRet.port_a, port_retAir)
    annotation (Line(points={{360,40},{402,40}}, color={0,127,255}));
  connect(cooCoi.port_a1, port_cooCoiIn) annotation (Line(points={{82,-52},{120,
          -52},{120,-400}},                 color={0,127,255}));
  connect(cooCoi.port_b1, port_CooCoiOut) annotation (Line(points={{62,-52},{50,
          -52},{50,-300},{40,-300},{40,-400}},
                                      color={0,127,255}));
  connect(heaCoi.port_a1, port_heaCoiIn) annotation (Line(points={{20,-52},{30,-52},
          {30,-180},{-40,-180},{-40,-400}},color={0,127,255}));
  connect(heaCoi.port_b1, port_heaCoiOut) annotation (Line(points={{0,-52},{-20,
          -52},{-20,-160},{-120,-160},{-120,-400}}, color={0,127,255}));

  connect(TRet.port_b, resRet.port_a)
    annotation (Line(points={{340,40},{160,40}}, color={0,127,255}));
  connect(resRet.port_b, eco.port_Sup) annotation (Line(points={{140,40},{-68,40},
          {-68,8},{-80,8}}, color={0,127,255}));
  connect(eco.yExh, yEcoExh)
    annotation (Line(points={{-83,14},{-83,320},{-420,320}}, color={0,0,127}));
  connect(eco.yOut, yEcoOut)
    annotation (Line(points={{-90,14},{-90,280},{-420,280}}, color={0,0,127}));
  connect(eco.yRet, yEcoRet) annotation (Line(points={{-96.8,14},{-98,14},{-98,222},
          {-260,222},{-260,240},{-420,240}}, color={0,0,127}));
  connect(senTMix.T, TAirMix) annotation (Line(points={{-50,-29},{-48,-29},{-48,
          360},{410,360}}, color={0,0,127}));
  connect(senTSup.T, TAirSup)
    annotation (Line(points={{320,-29},{320,320},{410,320}}, color={0,0,127}));
  connect(TRet.T, TAirRet)
    annotation (Line(points={{350,51},{350,280},{410,280}}, color={0,0,127}));
  connect(senVOut_flow.V_flow, VOut_flow) annotation (Line(points={{-150,51},{-150,
          240},{410,240}}, color={0,0,127}));
  connect(yFanSup, fanSup.y) annotation (Line(points={{-420,360},{-80,360},{-80,
          342},{230,342},{230,-28}}, color={0,0,127}));
  connect(fanSup.port_b, senTSup.port_a)
    annotation (Line(points={{240,-40},{310,-40}}, color={0,127,255}));
  connect(cooCoi.port_b2, resSup.port_a)
    annotation (Line(points={{82,-40},{140,-40}}, color={0,127,255}));
  annotation (Diagram(coordinateSystem(extent={{-400,-400},{400,400}})), Icon(
        coordinateSystem(extent={{-400,-400},{400,400}})));
end VAVAHU;
