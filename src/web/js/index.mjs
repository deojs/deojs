import "../css/css.js";

function test() {
    const testElement = document.createElement('h2');
    testElement.innerText = 'Hello!'

    return testElement;
}

document.body.appendChild(test());