// webpack.config.js
module.exports = {
  entry: {
    app: [
      './index.js'
    ]
  },

  output: {
    filename: '[name].js',
  },

  module: {
    rules: [
      {
        test:    /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use:  ['elm-webpack-loader?verbose=true&warn=true'],
      },
      {
        test: /\.css$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [ 'style-loader', 'css-loader' ]
      }
    ],
    noParse: /\.elm$/,
  },

  devServer: {
    inline: true,
    stats: { colors: true },
  }
};
