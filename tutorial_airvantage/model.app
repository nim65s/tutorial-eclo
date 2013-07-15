<?xml version="1.0" encoding="UTF-8"?><app:application xmlns:app="http://www.sierrawireless.com/airvantage/application/1.0" name="eclo" revision="0.4" type="tutorial_eclo">
  <capabilities>
    <communication>
      <protocol comm-id="SERIAL" type="M3DA">
        <parameter name="authentication" value="none"/>
        <parameter name="cipher" value="none"/>
      </protocol>
    </communication>
    <data>
      <encoding type="M3DA">
        <asset default-label="tutorial_eclo" id="greenhouse">
          <node default-label="Data" path="data">
            <variable default-label="Temperature (°C)" path="temperature" type="double"/>
            <variable default-label="Luminosity (Lux)" path="luminosity" type="double"/>
            <variable default-label="Humidity (%)" path="humidity" type="double"/>
            <variable default-label="Opening (°)" path="servo" type="double"/>
            <variable default-label="Button" path="btn" type="int"/>
            <command default-label="Open" path="servoCommand">
              <description>Give an opening angle to the roof, from 0° for closed to 100° to opened.</description>
              <parameter default-label="Requested state of roof." default-value="0" id="servoCommand" type="int">
                <constraints>
                  <bounds min="0" max="100"/>
                </constraints>
              </parameter>
            </command>
          </node>
        </asset>
      </encoding>
    </data>
  </capabilities>
  <application-manager use="MIHINI_APPCON"/>
  <binaries>
    <binary file="tutorial_mihini.tar"/>
  </binaries>
</app:application>
