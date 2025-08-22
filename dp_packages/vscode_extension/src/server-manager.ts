import axios, { AxiosResponse } from "axios";
import * as child_process from "child_process";
import * as path from "path";
import * as vscode from "vscode";

/**
 * Manages the DPug server process and health checks
 */
export class DpugServerManager {
  private serverProcess: child_process.ChildProcess | null = null;
  private outputChannel: vscode.OutputChannel;
  private isServerStarting: boolean = false;
  private serverReady: boolean = false;

  constructor(outputChannel: vscode.OutputChannel) {
    this.outputChannel = outputChannel;
  }

  /**
   * Ensure the DPug server is running
   */
  async ensureServerRunning(): Promise<boolean> {
    try {
      // First check if server is already running
      if (await this.isServerHealthy()) {
        this.outputChannel.appendLine(
          "DPug server is already running and healthy"
        );
        this.serverReady = true;
        return true;
      }

      // If server is starting, wait for it
      if (this.isServerStarting) {
        this.outputChannel.appendLine("DPug server is starting, waiting...");
        return await this.waitForServerReady();
      }

      // Check if auto-start is enabled
      const config = vscode.workspace.getConfiguration("dpug");
      const autoStart = config.get<boolean>("server.autoStart", true);

      if (!autoStart) {
        this.outputChannel.appendLine(
          "Auto-start disabled, server not started"
        );
        return false;
      }

      // Start the server
      return await this.startServer();
    } catch (error) {
      this.outputChannel.appendLine(
        `Failed to ensure server running: ${error}`
      );
      return false;
    }
  }

  /**
   * Check if the server is healthy
   */
  private async isServerHealthy(): Promise<boolean> {
    try {
      const config = vscode.workspace.getConfiguration("dpug");
      const serverHost = config.get<string>("server.host", "localhost");
      const serverPort = config.get<number>("server.port", 8080);

      const response: AxiosResponse<string> = await axios.get(
        `http://${serverHost}:${serverPort}/health`,
        { timeout: 2000 }
      );

      return response.status === 200 && response.data === "ok";
    } catch (error) {
      return false;
    }
  }

  /**
   * Start the DPug server using dpug_cli
   */
  private async startServer(): Promise<boolean> {
    try {
      this.isServerStarting = true;
      this.outputChannel.appendLine("Starting DPug server...");

      const config = vscode.workspace.getConfiguration("dpug");
      const serverPort = config.get<number>("server.port", 8080);

      // Find the dpug_cli executable
      const dpugCliPath = await this.findDpugCliPath();

      if (!dpugCliPath) {
        throw new Error(
          "Could not find dpug CLI executable. Please ensure dpug_cli is installed."
        );
      }

      // Check if we need to run with dart executable
      const isDartFile = dpugCliPath.endsWith(".dart");
      const command = isDartFile ? "dart" : dpugCliPath;
      const args = isDartFile
        ? [
            dpugCliPath,
            "server",
            "start",
            "--port",
            serverPort.toString(),
            "--host",
            "localhost",
          ]
        : [
            "server",
            "start",
            "--port",
            serverPort.toString(),
            "--host",
            "localhost",
          ];

      this.outputChannel.appendLine(
        `Starting server with command: ${command} ${args.join(" ")}`
      );

      // Start the server process
      this.serverProcess = child_process.spawn(command, args, {
        stdio: ["pipe", "pipe", "pipe"],
        detached: false,
        shell: false,
      });

      // Handle process output
      this.serverProcess.stdout?.on("data", (data) => {
        const output = data.toString();
        this.outputChannel.appendLine(`[Server] ${output.trim()}`);
      });

      this.serverProcess.stderr?.on("data", (data) => {
        const output = data.toString();
        this.outputChannel.appendLine(`[Server Error] ${output.trim()}`);
      });

      // Handle process exit
      this.serverProcess.on("exit", (code, signal) => {
        this.outputChannel.appendLine(
          `DPug server exited with code ${code}, signal ${signal}`
        );
        this.serverProcess = null;
        this.serverReady = false;
        this.isServerStarting = false;
      });

      this.serverProcess.on("error", (error) => {
        this.outputChannel.appendLine(
          `DPug server process error: ${error.message}`
        );
        this.serverProcess = null;
        this.serverReady = false;
        this.isServerStarting = false;
      });

      // Wait for server to be ready
      return await this.waitForServerReady();
    } catch (error) {
      this.outputChannel.appendLine(`Failed to start DPug server: ${error}`);
      this.isServerStarting = false;
      return false;
    }
  }

  /**
   * Wait for server to be ready
   */
  private async waitForServerReady(timeout: number = 30000): Promise<boolean> {
    const startTime = Date.now();

    while (Date.now() - startTime < timeout) {
      if (await this.isServerHealthy()) {
        this.outputChannel.appendLine("DPug server is ready");
        this.serverReady = true;
        this.isServerStarting = false;
        return true;
      }

      // Wait 1 second before checking again
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }

    this.outputChannel.appendLine(
      "Timeout waiting for DPug server to be ready"
    );
    this.isServerStarting = false;
    return false;
  }

  /**
   * Find the dpug CLI executable path
   */
  private async findDpugCliPath(): Promise<string | null> {
    try {
      // First try to find it in the workspace dp_packages folder
      const workspaceFolders = vscode.workspace.workspaceFolders;
      if (workspaceFolders) {
        const workspacePath = workspaceFolders[0].uri.fsPath;
        const possiblePaths = [
          path.join(workspacePath, "dpug_cli", "bin", "dpug.dart"),
          path.join(workspacePath, "dpug_cli", "bin", "dpug"),
          path.join(workspacePath, "..", "dpug_cli", "bin", "dpug.dart"),
          path.join(workspacePath, "..", "dpug_cli", "bin", "dpug"),
        ];

        for (const possiblePath of possiblePaths) {
          try {
            await vscode.workspace.fs.stat(vscode.Uri.file(possiblePath));
            this.outputChannel.appendLine(`Found dpug CLI at: ${possiblePath}`);
            return possiblePath;
          } catch {
            // Continue to next path
          }
        }
      }

      // Try to find it in PATH
      try {
        const which = await new Promise<string>((resolve, reject) => {
          child_process.exec("which dpug", (error, stdout) => {
            if (error) {
              reject(error);
            } else {
              resolve(stdout.trim());
            }
          });
        });

        if (which) {
          this.outputChannel.appendLine(`Found dpug CLI in PATH: ${which}`);
          return which;
        }
      } catch {
        // dpug not in PATH, continue to fallback
      }

      // Try to find dart executable to run dpug.dart directly
      try {
        const dartPath = await new Promise<string>((resolve, reject) => {
          child_process.exec("which dart", (error, stdout) => {
            if (error) {
              reject(error);
            } else {
              resolve(stdout.trim());
            }
          });
        });

        if (dartPath && workspaceFolders) {
          const workspacePath = workspaceFolders[0].uri.fsPath;
          const dpugDartPath = path.join(
            workspacePath,
            "dpug_cli",
            "bin",
            "dpug.dart"
          );
          try {
            await vscode.workspace.fs.stat(vscode.Uri.file(dpugDartPath));
            this.outputChannel.appendLine(
              `Found dpug.dart, will run with dart: ${dpugDartPath}`
            );
            return dpugDartPath;
          } catch {
            // Continue
          }
        }
      } catch {
        // dart not found, continue
      }

      return null;
    } catch (error) {
      this.outputChannel.appendLine(`Error finding dpug CLI: ${error}`);
      return null;
    }
  }

  /**
   * Stop the server if it's running
   */
  async stopServer(force: boolean = false): Promise<void> {
    if (this.serverProcess) {
      // Check if auto-stop is enabled unless forced
      if (!force) {
        const config = vscode.workspace.getConfiguration("dpug");
        const autoStop = config.get<boolean>("server.autoStop", true);
        if (!autoStop) {
          this.outputChannel.appendLine(
            "Auto-stop disabled, server not stopped"
          );
          return;
        }
      }

      this.outputChannel.appendLine("Stopping DPug server...");

      try {
        // Try graceful shutdown first
        if (process.platform === "win32") {
          child_process.execSync(
            `taskkill /pid ${this.serverProcess.pid} /t /f`
          );
        } else {
          this.serverProcess.kill("SIGTERM");
          // Wait a bit for graceful shutdown
          await new Promise((resolve) => setTimeout(resolve, 2000));
          if (this.serverProcess && !this.serverProcess.killed) {
            this.serverProcess.kill("SIGKILL");
          }
        }
      } catch (error) {
        this.outputChannel.appendLine(`Error stopping server: ${error}`);
      }

      this.serverProcess = null;
      this.serverReady = false;
      this.isServerStarting = false;
    }
  }

  /**
   * Get server status for display
   */
  getServerStatus(): { running: boolean; starting: boolean; ready: boolean } {
    return {
      running: this.serverProcess !== null,
      starting: this.isServerStarting,
      ready: this.serverReady,
    };
  }
}
