import axios, { AxiosResponse } from "axios";
import * as vscode from "vscode";
import {
  activateLanguageServer,
  deactivateLanguageServer,
} from "./language-server";

let outputChannel: vscode.OutputChannel;

// Extension activation
export function activate(context: vscode.ExtensionContext): void {
  outputChannel = vscode.window.createOutputChannel("DPug");

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
    formatOnSave
  );

  // Start the language server
  activateLanguageServer(context);

  outputChannel.appendLine(
    "DPug extension activated with language server support"
  );
}

// Extension deactivation
export function deactivate(): void {
  // Stop the language server
  deactivateLanguageServer();

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
    const message = error.response?.data || error.message || "Unknown error";
    vscode.window.showErrorMessage(`Conversion failed: ${message}`);
    outputChannel.appendLine(`Conversion error: ${message}`);
  }
}
