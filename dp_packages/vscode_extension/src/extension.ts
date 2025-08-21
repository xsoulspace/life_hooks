import axios from "axios";
import * as vscode from "vscode";

let outputChannel: vscode.OutputChannel;

export function activate(context: vscode.ExtensionContext) {
  outputChannel = vscode.OutputChannel =
    vscode.window.createOutputChannel("DPug");

  // Register format command
  const formatCommand = vscode.commands.registerCommand(
    "dpug.formatDocument",
    () => {
      formatCurrentDocument();
    }
  );

  // Register convert to Dart command
  const toDartCommand = vscode.commands.registerCommand("dpug.toDart", () => {
    convertToDart();
  });

  // Register convert from Dart command
  const fromDartCommand = vscode.commands.registerCommand(
    "dpug.fromDart",
    () => {
      convertFromDart();
    }
  );

  // Register format on save
  const formatOnSave = vscode.workspace.onDidSaveTextDocument((document) => {
    if (document.languageId === "dpug") {
      const config = vscode.workspace.getConfiguration("dpug");
      if (config.get("formatting.formatOnSave", true)) {
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

  outputChannel.appendLine("DPug extension activated");
}

export function deactivate() {
  outputChannel.dispose();
}

async function formatCurrentDocument() {
  const document = vscode.window.activeTextEditor?.document;
  if (document && document.languageId === "dpug") {
    await formatDocument(document);
  } else {
    vscode.window.showErrorMessage("No active DPug document to format");
  }
}

async function formatDocument(document: vscode.TextDocument) {
  try {
    const config = vscode.workspace.getConfiguration("dpug");
    const serverHost = config.get("server.host", "localhost");
    const serverPort = config.get("server.port", 8080);

    const response = await axios.post(
      `http://${serverHost}:${serverPort}/format/dpug`,
      {
        source: document.getText(),
      },
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
  } catch (error) {
    const message = error.response?.data || error.message;
    vscode.window.showErrorMessage(`Formatting failed: ${message}`);
    outputChannel.appendLine(`Formatting error: ${message}`);
  }
}

async function convertToDart() {
  const document = vscode.window.activeTextEditor?.document;
  if (!document || document.languageId !== "dpug") {
    vscode.window.showErrorMessage("No active DPug document to convert");
    return;
  }

  try {
    const config = vscode.workspace.getConfiguration("dpug");
    const serverHost = config.get("server.host", "localhost");
    const serverPort = config.get("server.port", 8080);

    const response = await axios.post(
      `http://${serverHost}:${serverPort}/dpug/to-dart`,
      {
        source: document.getText(),
      },
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
  } catch (error) {
    const message = error.response?.data || error.message;
    vscode.window.showErrorMessage(`Conversion failed: ${message}`);
    outputChannel.appendLine(`Conversion error: ${message}`);
  }
}

async function convertFromDart() {
  const document = vscode.window.activeTextEditor?.document;
  if (!document || document.languageId !== "dart") {
    vscode.window.showErrorMessage("No active Dart document to convert");
    return;
  }

  try {
    const config = vscode.workspace.getConfiguration("dpug");
    const serverHost = config.get("server.host", "localhost");
    const serverPort = config.get("server.port", 8080);

    const response = await axios.post(
      `http://${serverHost}:${serverPort}/dart/to-dpug`,
      {
        source: document.getText(),
      },
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
  } catch (error) {
    const message = error.response?.data || error.message;
    vscode.window.showErrorMessage(`Conversion failed: ${message}`);
    outputChannel.appendLine(`Conversion error: ${message}`);
  }
}
