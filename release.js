const crypto = require('crypto');
const fs = require('fs/promises');
const path = require('path');
const child_process = require('child_process');

const main = async () => {
  child_process.execSync('latexmk -pdf');
  const pdf = await fs.readFile(
    path.join(process.cwd(), 'resume.pdf')
  );

  const md5 = crypto.createHash('md5').update(pdf).digest('hex');
  const sha1 = crypto.createHash('sha1').update(pdf).digest('hex');
  const sha256 = crypto.createHash('sha256').update(pdf).digest('hex');

  const verify = {md5, sha1, sha256};

  await fs.writeFile(
    path.join(process.cwd(), 'verify.json'),
    JSON.stringify(verify),
  );

  const today = new Date();
  const tag = `${today.getFullYear()}.${today.getMonth() + 1}.${today.getDate(0)}`
  child_process.execSync(`gh release create "${tag}" resume.pdf verify.json`);
};

main();