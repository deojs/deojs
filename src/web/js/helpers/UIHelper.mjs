import "bootstrap";
import Split from "split.js";
import "../../css/css.js";
import Sortable from "sortablejs";

class UIHelper {
    constructor(app) {
        this.app = app;
        this.opSplit = null;
        this.ioSplit = null;
    }

    /**
     * Initialise the split panes in the UI
     */
    createSplits() {
        if (this.opSplit !== null) {
            this.opSplit.destroy();
        }
        if (this.ioSplit !== null) {
            this.ioSplit.destroy();
        }

        this.opSplit = Split(["#opPane", "#ioPane"], {
            sizes: [20, 80],
            minSize: 200
        });
        this.ioSplit = Split(["#flowPane", "#outputPane"], {
            sizes: [60, 40],
            minSize: 200,
            direction: "vertical"
        });
    }

    /**
     * Adds the "flowItem" class to a list item when added to the list
     *
     * @param event - SortableJs onAdd event object
     */
    onFunctionAdded(event) {
        event.item.classList.add("flowItem");
    }

    /**
     * Initialises the sortable lists and populates the operations list
     */
    createSortableLists() {
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
            },
            delay: 0
        });
        Sortable.create(flowListElement, {
            animation: 200,
            easing: "cubic-bezier(1, 0, 0, 1)",
            group: {
                name: "operationsGroup"
            },
            onAdd: this.onFunctionAdded,
            delay: 0
        });
    }

    /**
     * Adds relevant event listeners to the UI
     */
    addEventListeners() {
        // Input
        document.getElementById("inputFileButton").addEventListener("change", this.loadFiles.bind(this));
    }

    /**
     * Setup function for the entire app
     */
    setupUI() {
        this.createSplits();
        this.createSortableLists();
        this.addEventListeners();
    }

    /**
     *  test!
     * @param file
     */
    testFileLoaded(file) {
        console.log(file);
    }

    /**
     * Sends the selected input file to the InputHelper
     *
     * @param {Event} event - Input event
     */
    loadFiles(event) {
        const element = event.target;
        if (element.files.length > 0) {
            this.app.InputHelper.loadFile(element.files[0], this.testFileLoaded);
        }
    }
}

export default UIHelper;
