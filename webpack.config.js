const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = {
    mode: "development",
    entry: "./src/web/js/index.mjs",
    plugins: [
        new HtmlWebpackPlugin({
            template: "./src/web/html/index.html"
        })
    ],
    module: {
        rules: [
            {
                test: /\.worker\.m?js$/,
                exclude: /node_modules/,
                use: { loader: "worker-loader" }
            },
            {
                test: /\.m?js$/,
                exclude: /node_modules/,
                use: {
                    loader: "babel-loader",
                    options: {
                        presets: ["@babel/preset-env"]
                    }
                }
            },
            {
                test: /\.css$/i,
                use: ["style-loader", "css-loader", "postcss-loader"]
            },
            {
                test: /\.s[ac]ss$/i,
                use: ["style-loader", "css-loader", "postcss-loader", "sass-loader"]
            }
        ]
    }
};
