import "bootstrap";
import Split from "split.js";
import "../css/css.js";
import Sortable from "sortablejs";

import App from "./workers/App.worker.js";

const app = new App();

app.postMessage({ msg: "sent!" });

/**
 * Initialise the split panes in the UI
 */
function createSplits() {
    let opSplit;
    let ioSplit;
    if (opSplit) {
        opSplit.destroy();
    }
    if (ioSplit) {
        ioSplit.destroy();
    }

    Split(["#opPane", "#ioPane"], {
        sizes: [25, 75],
        minSize: 200
    });
    Split(["#flowPane", "#outputPane"], {
        sizes: [50, 50],
        minSize: 200,
        direction: "vertical"
    });
}
/**
 * Adds the "flowItem" class to a list item when added to the list
 *
 * @param event - SortableJs onAdd event object
 */
function onFunctionAdded(event) {
    event.item.classList.add("flowItem");
}

/**
 * Initialises the sortable lists and populates the operations list
 */
function createLists() {
    const opListElement = document.getElementById("operationsList");
    const flowListElement = document.getElementById("flowList");

    Sortable.create(opListElement, {
        animation: 200,
        easing: "cubic-bezier(1, 0, 0, 1)",
        sort: false,
        group: {
            name: "operationsGroup",
            pull: "clone",
            put: false
        }
    });
    Sortable.create(flowListElement, {
        animation: 200,
        easing: "cubic-bezier(1, 0, 0, 1)",
        group: {
            name: "operationsGroup"
        },
        onAdd: onFunctionAdded
    });
}

/**
 * Setup function for the entire app
 */
function setup() {
    createSplits();
    createLists();
}

setup();
