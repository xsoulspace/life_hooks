import {
  CompletionItem,
  CompletionItemKind,
  createConnection,
  DidChangeConfigurationNotification,
  InitializeParams,
  InitializeResult,
  MarkupContent,
  ProposedFeatures,
  SignatureInformation,
  TextDocuments,
  TextDocumentSyncKind,
} from "vscode-languageserver/node";

import { TextDocument } from "vscode-languageserver-textdocument";

// Create a connection for the server, using Node's IPC as a transport.
// Also include all preview / proposed LSP features.
const connection = createConnection(ProposedFeatures.all);

// Create a simple text document manager.
const documents: TextDocuments<TextDocument> = new TextDocuments(TextDocument);

let hasConfigurationCapability = false;
let hasWorkspaceFolderCapability = false;
let hasDiagnosticRelatedInformationCapability = false;

connection.onInitialize((params: InitializeParams) => {
  const capabilities = params.capabilities;

  // Does the client support the `workspace/configuration` request?
  // If not, we fall back using global settings.
  hasConfigurationCapability = !!(
    capabilities.workspace && !!capabilities.workspace.configuration
  );
  hasWorkspaceFolderCapability = !!(
    capabilities.workspace && !!capabilities.workspace.workspaceFolders
  );
  hasDiagnosticRelatedInformationCapability = !!(
    capabilities.textDocument &&
    capabilities.textDocument.publishDiagnostics &&
    capabilities.textDocument.publishDiagnostics.relatedInformation
  );

  const result: InitializeResult = {
    capabilities: {
      textDocumentSync: TextDocumentSyncKind.Incremental,
      // Tell the client that this server supports code completion.
      completionProvider: {
        resolveProvider: true,
        triggerCharacters: [".", "@", ".."],
      },
      // Tell the client that this server supports hover.
      hoverProvider: true,
      // Tell the client that this server supports signature help.
      signatureHelpProvider: {
        triggerCharacters: ["(", ","],
        retriggerCharacters: [","],
      },
      // Tell the client that this server supports go to definition.
      definitionProvider: true,
      // Tell the client that this server supports find references.
      referencesProvider: true,
      // Tell the client that this server supports document symbols.
      documentSymbolProvider: true,
    },
  };
  return result;
});

connection.onInitialized(() => {
  if (hasConfigurationCapability) {
    // Register for all configuration changes.
    connection.client.register(
      DidChangeConfigurationNotification.type,
      undefined
    );
  }
  if (hasWorkspaceFolderCapability) {
    connection.workspace.onDidChangeWorkspaceFolders((_event) => {
      connection.console.log("Workspace folder change event received.");
    });
  }
});

// The example settings
interface DPugSettings {
  maxNumberOfProblems: number;
}

// The global settings, used when the `workspace/configuration` request is not supported by the client.
// Please note that this is not the case when using this server with the client provided in this example
// but could happen with other clients.
const defaultSettings: DPugSettings = { maxNumberOfProblems: 1000 };
let globalSettings: DPugSettings = defaultSettings;

// Cache the settings of all open documents
const documentSettings: Map<string, Thenable<DPugSettings>> = new Map();

connection.onDidChangeConfiguration((change) => {
  if (hasConfigurationCapability) {
    // Reset all cached document settings
    documentSettings.clear();
  } else {
    globalSettings = <DPugSettings>(change.settings.dpug || defaultSettings);
  }

  // Revalidate all open text documents
  documents.all().forEach(validateTextDocument);
});

function getDocumentSettings(resource: string): Thenable<DPugSettings> {
  if (!hasConfigurationCapability) {
    return Promise.resolve(globalSettings);
  }
  let result = documentSettings.get(resource);
  if (!result) {
    result = connection.workspace.getConfiguration({
      scopeUri: resource,
      section: "dpug",
    });
    documentSettings.set(resource, result);
  }
  return result;
}

// Only keep settings for open documents
documents.onDidClose((e) => {
  documentSettings.delete(e.document.uri);
});

// The content of a text document has changed. This event is emitted
// when the text document first opened or when its content has changed.
documents.onDidChangeContent((change) => {
  validateTextDocument(change.document);
});

async function validateTextDocument(textDocument: TextDocument): Promise<void> {
  // In this simple example we get the settings for every validate run.
  const settings = await getDocumentSettings(textDocument.uri);

  // The validator creates diagnostics for all uppercase words length 2 and more
  const text = textDocument.getText();
  const pattern = /\b[A-Z]{2,}\b/g;
  let m: RegExpExecArray | null;

  let problems = 0;
  const diagnostics = [];
  while ((m = pattern.exec(text)) && problems < settings.maxNumberOfProblems) {
    problems++;
    const diagnostic = {
      severity: 2, // Warning
      range: {
        start: textDocument.positionAt(m.index),
        end: textDocument.positionAt(m.index + m[0].length),
      },
      message: `${m[0]} is all uppercase.`,
      source: "dpug-lsp",
    };
    diagnostics.push(diagnostic);
  }

  // Send the computed diagnostics to VSCode.
  connection.sendDiagnostics({ uri: textDocument.uri, diagnostics });
}

connection.onDidChangeWatchedFiles((_change) => {
  // Monitored files have change in VSCode
  connection.console.log("We received an file change event");
});

// This handler provides the initial list of the completion items.
connection.onCompletion((_textDocumentPosition) => {
  // The pass parameter contains the position of the text document in
  // which code complete got requested. For the example we ignore this
  // info and always provide the same completion items.
  return [
    {
      label: "Text",
      kind: CompletionItemKind.Class,
      data: 1,
      detail: "Flutter Text widget",
      documentation: "A widget that displays text",
    },
    {
      label: "Column",
      kind: CompletionItemKind.Class,
      data: 2,
      detail: "Flutter Column widget",
      documentation: "A widget that displays its children in a vertical array",
    },
    {
      label: "Container",
      kind: CompletionItemKind.Class,
      data: 3,
      detail: "Flutter Container widget",
      documentation:
        "A convenience widget that combines common painting, positioning, and sizing widgets",
    },
    {
      label: "@stateful",
      kind: CompletionItemKind.Annotation,
      data: 4,
      detail: "DPug stateful annotation",
      documentation: "Marks a class as stateful with reactive state management",
    },
    {
      label: "@listen",
      kind: CompletionItemKind.Annotation,
      data: 5,
      detail: "DPug listen annotation",
      documentation: "Creates a reactive state field with getter/setter",
    },
  ];
});

// This handler resolves additional information for the item selected in
// the completion list.
connection.onCompletionResolve((item: CompletionItem) => {
  if (item.data === 1) {
    item.detail = "Flutter Text widget";
    item.documentation = "A widget that displays text with an optional style.";
  } else if (item.data === 2) {
    item.detail = "Flutter Column widget";
    item.documentation =
      "A widget that displays its children in a vertical array.";
  } else if (item.data === 3) {
    item.detail = "Flutter Container widget";
    item.documentation =
      "A convenience widget that combines common painting, positioning, and sizing widgets.";
  } else if (item.data === 4) {
    item.detail = "DPug @stateful annotation";
    item.documentation =
      "Marks a class as stateful with reactive state management using @listen fields.";
  } else if (item.data === 5) {
    item.detail = "DPug @listen annotation";
    item.documentation =
      "Creates a reactive state field with automatic getter/setter generation.";
  }
  return item;
});

// This handler provides hover information for symbols
connection.onHover((params) => {
  const document = documents.get(params.textDocument.uri);
  if (!document) {
    return null;
  }

  const word = getWordAtPosition(document, params.position);
  if (!word) {
    return null;
  }

  // Provide hover information for common DPug/Flutter constructs
  const hoverMap: { [key: string]: string } = {
    "@stateful": "Marks a class as stateful with reactive state management",
    "@listen":
      "Creates a reactive state field with automatic getter/setter generation",
    Text: "A widget that displays text with an optional style",
    Column: "A widget that displays its children in a vertical array",
    Container:
      "A convenience widget that combines common painting, positioning, and sizing widgets",
    Widget: "Base class for all Flutter widgets",
    build:
      "Method that describes the part of the user interface represented by this widget",
  };

  const info = hoverMap[word];
  if (info) {
    const contents: MarkupContent = {
      kind: "markdown",
      value: `**${word}**\n\n${info}`,
    };
    return { contents };
  }

  return null;
});

// This handler provides signature help for function calls
connection.onSignatureHelp((params) => {
  const document = documents.get(params.textDocument.uri);
  if (!document) {
    return null;
  }

  // Simple signature help for common widgets
  const signatures: SignatureInformation[] = [
    {
      label: "Text(data, {Key? key, TextStyle? style, ...})",
      documentation: "Creates a text widget",
      parameters: [
        {
          label: "data",
          documentation: "The text to display",
        },
        {
          label: "key",
          documentation:
            "Controls how one widget replaces another widget in the tree",
        },
        {
          label: "style",
          documentation: "The style to use for the text",
        },
      ],
    },
    {
      label: "Column({Key? key, MainAxisAlignment mainAxisAlignment, ...})",
      documentation: "Creates a vertical array of children",
      parameters: [
        {
          label: "key",
          documentation:
            "Controls how one widget replaces another widget in the tree",
        },
        {
          label: "mainAxisAlignment",
          documentation:
            "How the children should be placed along the main axis",
        },
      ],
    },
  ];

  return { signatures, activeSignature: 0, activeParameter: 0 };
});

// This handler provides go to definition functionality
connection.onDefinition((params) => {
  const document = documents.get(params.textDocument.uri);
  if (!document) {
    return null;
  }

  const word = getWordAtPosition(document, params.position);
  if (!word) {
    return null;
  }

  // Simple definition provider - in a real implementation,
  // this would search through the codebase for definitions
  return null;
});

// This handler provides find references functionality
connection.onReferences((params) => {
  const document = documents.get(params.textDocument.uri);
  if (!document) {
    return null;
  }

  const word = getWordAtPosition(document, params.position);
  if (!word) {
    return null;
  }

  // Simple reference provider - in a real implementation,
  // this would search through the codebase for references
  return [];
});

// This handler provides document symbols
connection.onDocumentSymbol((params) => {
  const document = documents.get(params.textDocument.uri);
  if (!document) {
    return [];
  }

  const text = document.getText();
  const symbols = [];

  // Find class definitions
  const classRegex = /class\s+(\w+)/g;
  let match;
  while ((match = classRegex.exec(text)) !== null) {
    symbols.push({
      name: match[1],
      kind: 5, // Class
      range: {
        start: document.positionAt(match.index),
        end: document.positionAt(match.index + match[0].length),
      },
      selectionRange: {
        start: document.positionAt(match.index + 6), // Skip "class "
        end: document.positionAt(match.index + match[0].length),
      },
    });
  }

  return symbols;
});

// Helper function to get word at position
function getWordAtPosition(
  document: TextDocument,
  position: any
): string | null {
  const text = document.getText();
  const offset = document.offsetAt(position);

  // Find word boundaries
  let start = offset;
  let end = offset;

  // Move start backwards to find word start
  while (start > 0 && /\w/.test(text[start - 1])) {
    start--;
  }

  // Move end forwards to find word end
  while (end < text.length && /\w/.test(text[end])) {
    end++;
  }

  const word = text.substring(start, end);
  return word.length > 0 ? word : null;
}

// Make the text document manager listen on the connection
// for open, change and close text document events
documents.listen(connection);

// Listen on the connection
connection.listen();
