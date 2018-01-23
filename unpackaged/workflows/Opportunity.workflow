<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AmountUpdate</fullName>
        <field>Amount</field>
        <formula>Amount+1</formula>
        <name>AmountUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateAmount</fullName>
        <field>Amount</field>
        <formula>10</formula>
        <name>UpdateAmount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UpdateAmount</fullName>
        <actions>
            <name>AmountUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>NOT(ISNULL(Amount))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
