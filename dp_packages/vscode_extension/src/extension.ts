import axios, { AxiosResponse } from "axios";
import * as vscode from "vscode";
import {
  activateLanguageServer,
  deactivateLanguageServer,
} from "./language-server";
import { DpugServerManager } from "./server-manager";

let outputChannel: vscode.OutputChannel;
let serverManager: DpugServerManager;

// Extension activation
export async function activate(
  context: vscode.ExtensionContext
): Promise<void> {
  outputChannel = vscode.window.createOutputChannel("DPug");
  serverManager = new DpugServerManager(outputChannel);

  outputChannel.appendLine("Activating DPug extension...");

  // Start the DPug server automatically
  const serverStarted = await serverManager.ensureServerRunning();
  if (serverStarted) {
    outputChannel.appendLine("✓ DPug server started successfully");
  } else {
    outputChannel.appendLine("⚠ Failed to start DPug server automatically");
    vscode.window.showWarningMessage(
      "Failed to start DPug server. Some features may not work. Please start it manually with 'dpug server start' or check the DPug output channel for details."
    );
  }

  // Register format command
  const formatCommand = vscode.commands.registerCommand(
    "dpug.formatDocument",
    formatCurrentDocument
  );

  // Register convert to Dart command
  const toDartCommand = vscode.commands.registerCommand(
    "dpug.toDart",
    convertToDart
  );

  // Register convert from Dart command
  const fromDartCommand = vscode.commands.registerCommand(
    "dpug.fromDart",
    convertFromDart
  );

  // Register server management commands
  const startServerCommand = vscode.commands.registerCommand(
    "dpug.server.start",
    startServerManually
  );

  const stopServerCommand = vscode.commands.registerCommand(
    "dpug.server.stop",
    stopServerManually
  );

  const serverStatusCommand = vscode.commands.registerCommand(
    "dpug.server.status",
    showServerStatus
  );

  // Register format on save
  const formatOnSave = vscode.workspace.onDidSaveTextDocument((document) => {
    if (document.languageId === "dpug") {
      const config = vscode.workspace.getConfiguration("dpug");
      const shouldFormatOnSave = config.get<boolean>(
        "formatting.formatOnSave",
        true
      );
      if (shouldFormatOnSave) {
        formatDocument(document);
      }
    }
  });

  context.subscriptions.push(
    formatCommand,
    toDartCommand,
    fromDartCommand,
    startServerCommand,
    stopServerCommand,
    serverStatusCommand,
    formatOnSave
  );

  // Start the language server
  activateLanguageServer(context);

  outputChannel.appendLine(
    "✓ DPug extension activated with language server support"
  );

  // Show server status to user
  const serverStatus = serverManager.getServerStatus();
  if (serverStatus.ready) {
    vscode.window.showInformationMessage(
      "DPug extension activated. Server is running and ready."
    );
  }
}

// Extension deactivation
export async function deactivate(): Promise<void> {
  outputChannel.appendLine("Deactivating DPug extension...");

  // Stop the DPug server
  if (serverManager) {
    await serverManager.stopServer(true); // Force stop on extension deactivation
  }

  // Stop the language server
  deactivateLanguageServer();

  outputChannel.appendLine("✓ DPug extension deactivated");
  outputChannel.dispose();
}

// Format the currently active document
async function formatCurrentDocument(): Promise<void> {
  const document = vscode.window.activeTextEditor?.document;
  if (document && document.languageId === "dpug") {
    await formatDocument(document);
  } else {
    vscode.window.showErrorMessage("No active DPug document to format");
  }
}

// Format a specific document
async function formatDocument(document: vscode.TextDocument): Promise<void> {
  try {
    const config = vscode.workspace.getConfiguration("dpug");
    const serverHost = config.get<string>("server.host", "localhost");
    const serverPort = config.get<number>("server.port", 8080);

    const response: AxiosResponse<string> = await axios.post(
      `http://${serverHost}:${serverPort}/format/dpug`,
      document.getText(),
      {
        headers: { "Content-Type": "text/plain" },
      }
    );

    const edit = new vscode.WorkspaceEdit();
    const fullRange = new vscode.Range(
      document.positionAt(0),
      document.positionAt(document.getText().length)
    );
    edit.replace(document.uri, fullRange, response.data);
    await vscode.workspace.applyEdit(edit);

    outputChannel.appendLine("Document formatted successfully");
  } catch (error: any) {
    const message = error.response?.data || error.message || "Unknown error";
    vscode.window.showErrorMessage(`Formatting failed: ${message}`);
    outputChannel.appendLine(`Formatting error: ${message}`);
  }
}

// Convert current DPug document to Dart
async function convertToDart(): Promise<void> {
  const document = vscode.window.activeTextEditor?.document;
  if (!document || document.languageId !== "dpug") {
    vscode.window.showErrorMessage("No active DPug document to convert");
    return;
  }

  try {
    const config = vscode.workspace.getConfiguration("dpug");
    const serverHost = config.get<string>("server.host", "localhost");
    const serverPort = config.get<number>("server.port", 8080);

    const response: AxiosResponse<string> = await axios.post(
      `http://${serverHost}:${serverPort}/dpug/to-dart`,
      document.getText(),
      {
        headers: { "Content-Type": "text/plain" },
      }
    );

    // Create new Dart document
    const dartDocument = await vscode.workspace.openTextDocument({
      language: "dart",
      content: response.data,
    });

    await vscode.window.showTextDocument(dartDocument);
    outputChannel.appendLine("Converted DPug to Dart successfully");
  } catch (error: any) {
    const message = error.response?.data || error.message || "Unknown error";
    vscode.window.showErrorMessage(`Conversion failed: ${message}`);
    outputChannel.appendLine(`Conversion error: ${message}`);
  }
}

// Convert current Dart document to DPug
async function convertFromDart(): Promise<void> {
  const document = vscode.window.activeTextEditor?.document;
  if (!document || document.languageId !== "dart") {
    vscode.window.showErrorMessage("No active Dart document to convert");
    return;
  }

  try {
    const config = vscode.workspace.getConfiguration("dpug");
    const serverHost = config.get<string>("server.host", "localhost");
    const serverPort = config.get<number>("server.port", 8080);

    const response: AxiosResponse<string> = await axios.post(
      `http://${serverHost}:${serverPort}/dart/to-dpug`,
      document.getText(),
      {
        headers: { "Content-Type": "text/plain" },
      }
    );

    // Create new DPug document
    const dpugDocument = await vscode.workspace.openTextDocument({
      language: "dpug",
      content: response.data,
    });

    await vscode.window.showTextDocument(dpugDocument);
    outputChannel.appendLine("Converted Dart to DPug successfully");
  } catch (error: any) {
    let message = error.response?.data || error.message || "Unknown error";
    let userMessage = `Conversion failed: ${message}`;

    // Provide helpful error messages for common issues
    if (message.includes("No supported class found")) {
      userMessage =
        "DPug conversion currently only supports StatefulWidget classes. Please convert your StatelessWidget to a StatefulWidget first.";
      outputChannel.appendLine(
        "DPug conversion only supports StatefulWidget classes"
      );
      outputChannel.appendLine("To convert a StatelessWidget, you can:");
      outputChannel.appendLine("1. Wrap it in a StatefulWidget");
      outputChannel.appendLine(
        "2. Use the DPug syntax directly in a .dpug file"
      );
    }

    vscode.window.showErrorMessage(userMessage);
    outputChannel.appendLine(`Conversion error: ${message}`);
  }
}

// Server management functions
async function startServerManually(): Promise<void> {
  try {
    outputChannel.appendLine("Manually starting DPug server...");
    const success = await serverManager.ensureServerRunning();

    if (success) {
      vscode.window.showInformationMessage("DPug server started successfully");
      outputChannel.appendLine("✓ DPug server started manually");
    } else {
      vscode.window.showErrorMessage("Failed to start DPug server");
      outputChannel.appendLine("✗ Failed to start DPug server manually");
    }
  } catch (error) {
    vscode.window.showErrorMessage(`Error starting server: ${error}`);
    outputChannel.appendLine(`Error starting server manually: ${error}`);
  }
}

async function stopServerManually(): Promise<void> {
  try {
    outputChannel.appendLine("Manually stopping DPug server...");
    await serverManager.stopServer();
    vscode.window.showInformationMessage("DPug server stopped");
    outputChannel.appendLine("✓ DPug server stopped manually");
  } catch (error) {
    vscode.window.showErrorMessage(`Error stopping server: ${error}`);
    outputChannel.appendLine(`Error stopping server manually: ${error}`);
  }
}

function showServerStatus(): void {
  const status = serverManager.getServerStatus();

  let statusMessage = "DPug Server Status:\n";
  statusMessage += `Running: ${status.running ? "Yes" : "No"}\n`;
  statusMessage += `Starting: ${status.starting ? "Yes" : "No"}\n`;
  statusMessage += `Ready: ${status.ready ? "Yes" : "No"}`;

  vscode.window.showInformationMessage(statusMessage);
  outputChannel.appendLine(`Server status: ${JSON.stringify(status)}`);
}
