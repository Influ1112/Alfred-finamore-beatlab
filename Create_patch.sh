/**
 * Sync UI assets from packages/ui -> apps/web/public/ui-assets and apps/mobile/assets/ui-assets
 *
 * Usage:
 *   node tools/sync-assets.js
 *
 * The script:
 *  - Copies everything in packages/ui/* to:
 *      - apps/web/public/ui-assets/
 *      - apps/mobile/assets/ui-assets/
 *  - Creates the destination directories if missing
 *  - Overwrites existing files
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const root = path.resolve(__dirname, "..");
const srcDir = path.join(root, "packages", "ui");
const webDest = path.join(root, "apps", "web", "public", "ui-assets");
const mobileDest = path.join(root, "apps", "mobile", "assets", "ui-assets");

async function ensureDir(dir) {
  await fs.promises.mkdir(dir, { recursive: true });
}

async function copyFile(src, dest) {
  await ensureDir(path.dirname(dest));
  await fs.promises.copyFile(src, dest);
}

async function copyDir(src, dest) {
  await ensureDir(dest);
  const entries = await fs.promises.readdir(src, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      await copyDir(srcPath, destPath);
    } else if (entry.isFile()) {
      await copyFile(srcPath, destPath);
      console.log(`Copied: ${path.relative(root, srcPath)} -> ${path.relative(root, destPath)}`);
    }
  }
}

async function main() {
  try {
    const srcExists = fs.existsSync(srcDir);
    if (!srcExists) {
      console.error(`Source directory not found: ${srcDir}`);
      process.exit(1);
    }

    console.log("Syncing UI assets...");
    await copyDir(srcDir, webDest);
    await copyDir(srcDir, mobileDest);
    console.log("Done. Web assets ->", webDest);
    console.log("Done. Mobile assets ->", mobileDest);
  } catch (err) {
    console.error("Asset sync failed:", err);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}
