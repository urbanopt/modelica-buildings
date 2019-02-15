within Buildings.Controls.OBC.OutdoorLights;
block DaylightControlled "Controlling the outdoor lighting based on daylight time"
  parameter Modelica.SIunits.Angle lat(displayUnit="deg") "Latitude";
  parameter Modelica.SIunits.Angle lon(displayUnit="deg") "Longitude";
  parameter Modelica.SIunits.Time timZon(displayUnit="h") "Time zone of location";

  CDL.Interfaces.RealOutput y "Output on/off control signal"
   annotation (Placement(transformation(extent={{100,-10},{120,10}})));

protected
  CDL.Utilities.SunRiseSet sunRiseSet(
  final lat=lat,
  final lon=lon,
  final timZon=timZon)
   annotation (Placement(transformation(extent={{-20,-10},{0,10}})));

equation
  y = if sunRiseSet.sunUp then 0 else 1;
annotation (
defaultComponentName="DaylightControlled",
Documentation(
info="<html>
<p>
This block outputs on/off control signals for outdoor lighting devices based on
daylight time.
The outdoor lights will be automatically turned off during daylight hours,
and turned on when there is no daylight.
</p>
<h4>Validation</h4>
<p>
A validation can be found at
<a href=\"modelica://Buildings.Controls.OBC.OutdoorLights.Validation.DaylightControlled\">
Buildings.Controls.OBC.OutdoorLights.Validation.DaylightControlled</a>.
</p>
</html>",
revisions="<html>
<ul>
<li>
Feb 13, 2019, by Kun Zhang:<br/>
First implementation.
</li>
</ul>
</html>"),
Icon(graphics={
        Rectangle(
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{22,70},{24,-96}},
          lineColor={28,108,200},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Line(points={{14,46},{32,46}}, color={0,0,0}),
        Line(points={{6,70},{40,70}}, color={0,0,0}),
        Rectangle(
          extent={{8,-96},{40,-98}},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None,
          lineColor={0,0,0}),
        Rectangle(
          extent={{14,72},{32,70}},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{22,80},{24,72}},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Polygon(
          points={{8,70},{10,70},{18,46},{16,46},{8,70}},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Polygon(
          points={{38,70},{36,70},{28,46},{30,46},{38,70}},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-100,100},{100,-102}},
          lineColor={0,0,0},
          pattern=LinePattern.None),
        Ellipse(
          extent={{-128,128},{-71.5,71.5}},
          lineColor={238,46,47},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          startAngle=0,
          endAngle=90,
          closure=EllipseClosure.None),
        Line(points={{-88,70},{-88,64}}, color={238,46,47}),
        Line(points={{-70,90},{-62,90}}, color={238,46,47}),
        Line(points={{-76,78},{-72,74}}, color={238,46,47})}));
end DaylightControlled;
