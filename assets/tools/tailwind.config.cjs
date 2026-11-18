const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../..');
function htmlFiles(directory) {
  return fs.readdirSync(directory, {withFileTypes: true}).flatMap(item => {
    const file = path.join(directory, item.name);
    return item.isDirectory() ? htmlFiles(file) : item.name.endsWith('.html') ? [file] : [];
  }).sort();
}
// Full class strings are extracted from HTML and inline JavaScript. These exact
// extra classes cover template-literal colour interpolation in the simulators.
const colours = ['slate','gray','zinc','neutral','stone','red','orange','amber','yellow','lime','green','emerald','teal','cyan','sky','blue','indigo','violet','purple','fuchsia','pink','rose'];
const safelist = colours.flatMap(colour => [400,500,600].flatMap(shade =>
  [`text-${colour}-${shade}`, `bg-${colour}-${shade}`, `border-${colour}-${shade}`, `bg-${colour}-${shade}/30`]));
module.exports = {content: htmlFiles(path.join(root, '05_LECTURES')), safelist, theme: {extend: {}}, plugins: []};
