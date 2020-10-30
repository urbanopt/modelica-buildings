within Buildings.Applications.DHC.CentralPlants.Heating.Generation1.Subsystems.Examples;
model BoilerSubsystem "Example model for boiler subsystem"
  extends Modelica.Icons.Example;
  package MediumWat =
      Modelica.Media.Interfaces.PartialMedium
    "Medium model for liquid water";
  package MediumSte =
      IBPSA.Media.Interfaces.PartialPureSubstanceWithSat
    "Medium model air water vapor";

  Buildings.Applications.DHC.CentralPlants.Heating.Generation1.Subsystems.BoilerSubsystem
    boiSubSys(redeclare package Medium_a = MediumWat, redeclare package
      Medium_b = MediumSte)
              "Boiler subsystem"
    annotation (Placement(transformation(extent={{0,0},{20,20}})));
  Fluid.Sources.Boundary_pT           sou(
    redeclare package Medium = MediumWat,
    use_p_in=false,
    p=101325,
    T=353.15,
    nPorts=1)
    "Source"
    annotation (Placement(transformation(extent={{-90,0},{-70,20}})));
  Fluid.FixedResistances.PressureDrop           dp1(redeclare package Medium =
        MediumWat,
    dp_nominal=300)
    "Pressure drop"
    annotation (Placement(transformation(extent={{-50,0},{-30,20}})));
  Fluid.FixedResistances.PressureDrop           dp2(redeclare package Medium =
        MediumSte,
    dp_nominal=3000)
    "Pressure drop"
    annotation (Placement(transformation(extent={{40,0},{60,20}})));
  Fluid.Sources.Boundary_pT           sin(
    redeclare package Medium = MediumSte,
    use_p_in=false,
    p=101325,
    T=353.15,
    nPorts=1)
    "Sink"
    annotation (Placement(transformation(extent={{90,0},{70,20}})));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end BoilerSubsystem;
