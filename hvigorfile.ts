import { Config } from 'hvigor';
import * as path from 'path';

const rootPath = path.resolve(__dirname, '../../');
const appPath = path.resolve(__dirname, './');

const flutterConfigs = {
    flutterPath: process.env.FLUTTER_ROOT,
    source: '../../',
    target: 'apps/app_ohos/lib/main.dart',
    build: 'aot',
    treeShake: true,
    dartDefine: {},
    packagePath: rootPath,
    appPath: appPath
};

export default <Config>{
    appName: 'app_ohos',
    appId: 'com.example.app_ohos',
    version: '1.0.0',
    description: 'A new Flutter project.',
    author: 'Your Name',
    email: 'your.email@example.com',
    website: 'https://example.com',
    license: 'MIT',
    dependencies: {
        flutter: 'any',
    },
    devDependencies: {
        flutter_test: 'any',
    },
    flutterBuildMode: '',
    flutter: {
        flutterPath: process.env.FLUTTER_ROOT,
        source: '../../',
        target: 'apps/app_ohos/lib/main.dart',
        build: 'aot',
        treeShake: true,
        dartDefine: {},
        packagePath: rootPath,
        appPath: appPath
    }
};

.apply()
    .plugin(flutterPlugin, flutterConfigs)
    .execute();