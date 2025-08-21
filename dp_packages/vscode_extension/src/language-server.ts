import * as path from "path";
import * as vscode from "vscode";
import { ExtensionContext, workspace } from "vscode";
import {
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
  TransportKind,
} from "vscode-languageclient/node";

let client: LanguageClient | undefined;

/**
 * Activates the DPug language server
 * @param context Extension context
 */
export function activateLanguageServer(context: ExtensionContext): void {
  // Server is implemented in Node.js
  const serverModule = context.asAbsolutePath(
    path.join("out", "server", "dpug-language-server.js")
  );

  // If the extension is launched in debug mode then the debug server options are used
  // Otherwise the run options are used
  const serverOptions: ServerOptions = {
    run: { module: serverModule, transport: TransportKind.ipc },
    debug: {
      module: serverModule,
      transport: TransportKind.ipc,
      options: { execArgv: ["--nolazy", "--inspect=6009"] },
    },
  };

  // Options to control the language client
  const clientOptions: LanguageClientOptions = {
    // Register the server for DPug documents
    documentSelector: [{ scheme: "file", language: "dpug" }],
    synchronize: {
      // Notify the server about file changes to '.clientrc files contained in the workspace
      fileEvents: workspace.createFileSystemWatcher("**/.clientrc"),
    },
    outputChannelName: "DPug Language Server",
    progressOnInitialization: true,
  };

  // Create the language client and start the client
  client = new LanguageClient(
    "dpugLanguageServer",
    "DPug Language Server",
    serverOptions,
    clientOptions
  );

  // Start the client. This will also launch the server
  client.start().catch((error) => {
    vscode.window.showErrorMessage(
      `Failed to start DPug language server: ${error.message}`
    );
  });
}

/**
 * Deactivates the DPug language server
 */
export function deactivateLanguageServer(): Thenable<void> | undefined {
  if (!client) {
    return undefined;
  }
  return client.stop();
}

/**
 * Gets the current language client instance
 */
export function getLanguageClient(): LanguageClient | undefined {
  return client;
}
