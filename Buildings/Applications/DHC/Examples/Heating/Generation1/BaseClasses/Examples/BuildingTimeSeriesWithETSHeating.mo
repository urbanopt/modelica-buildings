within Buildings.Applications.DHC.Examples.Heating.Generation1.BaseClasses.Examples;
model BuildingTimeSeriesWithETSHeating
  "Example model for the 1st generation building time series model with 1st generation district heating ETS"
  extends Modelica.Icons.Example;

  package MediumSte = IBPSA.Media.Steam "Steam medium";
  package MediumWat = IBPSA.Media.Specialized.Water.HighTemperature "Water medium";

  parameter String filNam=
    "modelica://Buildings/Resources/Data/Applications/DHC/Examples/Heating/Generation1/BaseClasses/Examples/Loads.txt"
    "Library path of the file with thermal loads as time series";
    //     "modelica://Buildings/Resources/Data/Applications/DHC/Examples/FirstGeneration/HeatingSystem-WP3-DESTEST/HeatingLoadProfiles.csv"

  parameter Modelica.SIunits.AbsolutePressure pSte=1000000
    "Steam pressure";
  parameter Modelica.SIunits.Temperature TSte=
    MediumSte.saturationTemperature_p(pSte)
    "Steam temperature";

  Fluid.Sources.Boundary_pT souSte(
    redeclare package Medium = MediumSte,
    p(displayUnit="Pa") = pSte,
    T=TSte,
    nPorts=1) "Steam source"
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
  Fluid.Sources.Boundary_pT watSin(
    redeclare package Medium = MediumWat,
    p=pSte - 50000,
    nPorts=1) "Water sink"
    annotation (Placement(transformation(extent={{60,0},{40,20}})));
  Buildings.Applications.DHC.Examples.Heating.Generation1.BaseClasses.BuildingTimeSeriesWithETSHeating
    buiWitETS(
    redeclare package MediumSte = MediumSte,
    redeclare package MediumWat = MediumWat,
    filNam=filNam,
    pSte_nominal=pSte,
    TSteSup_nominal=TSte,
    mDis_flow_nominal=5)
    annotation (Placement(transformation(extent={{-20,0},{0,20}})));

equation
  connect(souSte.ports[1], buiWitETS.port_a)
    annotation (Line(points={{-60,10},{-20,10}}, color={0,127,255}));
  connect(buiWitETS.port_b, watSin.ports[1])
    annotation (Line(points={{0,10},{40,10}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
  experiment(StopTime=31536000),
__Dymola_Commands(file=
          "Resources/Scripts/Dymola/Applications/DHC/Examples/Heating/Generation1/BaseClasses/Examples/BuildingTimeSeriesHeatingTableRead.mos"
        "Simulate and plot"));
end BuildingTimeSeriesWithETSHeating;
