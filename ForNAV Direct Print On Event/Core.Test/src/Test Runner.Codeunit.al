namespace BradFullwood.ForNAV.Tests;

/// <summary>
/// Test runner for Core extension tests.
/// Provides TestIsolation to automatically roll back database changes after each test codeunit.
/// </summary>
codeunit 77806 "BJF Test Runner"
{
    Subtype = TestRunner;
    TestIsolation = Codeunit;

    trigger OnRun()
    begin
        // Tests are run by the test framework
        // This trigger is called when the test runner is executed
    end;

    trigger OnBeforeTestRun(CodeunitID: Integer; CodeunitName: Text; FunctionName: Text; FunctionTestPermissions: TestPermissions): Boolean
    begin
        // Runs before each test method
        // Runs in its own transaction
    end;

    trigger OnAfterTestRun(CodeunitID: Integer; CodeunitName: Text; FunctionName: Text; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    begin
        // Runs after each test method
        // Runs in its own transaction
        // Database changes from the test method are rolled back due to TestIsolation = Codeunit
    end;
}
