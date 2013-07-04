<?xml version="1.0" encoding="UTF-8"?>
<app:application xmlns:app="http://www.sierrawireless.com/airvantage/application/1.0" type="com.test.myapplication" name="eclo" revision="0.1.0">
    <capabilities>

        <communication>
            <protocol comm-id="SERIAL" type="M3DA">
                <parameter name="authentication" value="none"/>
                <parameter name="cipher" value="none"/>
            </protocol>
        </communication>

        <data>
            <encoding type="M3DA">
                <asset default-label="eclo" id="greenhouse">
                    <node path="data">
                        <variable default-label="Temperature" path="temperature" type="double"/>
                        <setting default-label="Luminosity" path="luminosity" type="double"/>
                    </node>
                </asset>
            </encoding>
        </data>

    </capabilities>
</app:application>
