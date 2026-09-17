import DefaultTheme from "vitepress/theme";
import type { Theme } from "vitepress";
import { onMounted, watch, nextTick } from "vue";
import { useRoute } from "vitepress";
import mediumZoom from "medium-zoom";
import "./custom.css";

export default {
  extends: DefaultTheme,
  setup() {
    const route = useRoute();

    // Medium-zoom for images
    const initZoom = () => {
      mediumZoom(".main img", {
        background: "rgba(13, 17, 23, 0.95)",
      });
    };

    onMounted(() => {
      initZoom();
      initMermaidZoom();
    });

    watch(
      () => route.path,
      () =>
        nextTick(() => {
          initZoom();
          initMermaidZoom();
        })
    );

    // Mermaid click-to-zoom viewer
    function initMermaidZoom() {
      document.querySelectorAll(".mermaid").forEach((el) => {
        // Avoid double-binding
        if (el.getAttribute("data-zoom-bound")) return;
        el.setAttribute("data-zoom-bound", "true");

        el.addEventListener("click", () => {
          openMermaidViewer(el as HTMLElement);
        });
      });
    }

    function openMermaidViewer(mermaidEl: HTMLElement) {
      let scale = 1;
      let translateX = 0;
      let translateY = 0;
      let isDragging = false;
      let startX = 0;
      let startY = 0;

      // Create overlay
      const overlay = document.createElement("div");
      overlay.className = "mermaid-zoom-overlay";

      // Viewport
      const viewport = document.createElement("div");
      viewport.className = "mermaid-zoom-viewport";

      // Clone SVG content
      const svgEl = mermaidEl.querySelector("svg");
      if (!svgEl) return;
      const svgClone = svgEl.cloneNode(true) as SVGElement;
      svgClone.removeAttribute("width");
      svgClone.removeAttribute("height");
      svgClone.style.width = "auto";
      svgClone.style.height = "auto";
      svgClone.style.maxWidth = "85vw";
      svgClone.style.maxHeight = "80vh";
      viewport.appendChild(svgClone);

      // Controls
      const controls = document.createElement("div");
      controls.className = "mermaid-zoom-controls";
      controls.innerHTML = `
        <button class="mermaid-zoom-btn" data-action="zoom-in">+ Zoom In</button>
        <button class="mermaid-zoom-btn" data-action="zoom-out">− Zoom Out</button>
        <button class="mermaid-zoom-btn" data-action="fit">⊡ Fit</button>
        <button class="mermaid-zoom-btn" data-action="reset">↺ Reset</button>
        <button class="mermaid-zoom-btn" data-action="close">✕ Close</button>
      `;

      // Hint
      const hint = document.createElement("div");
      hint.className = "mermaid-zoom-hint";
      hint.textContent = "Scroll to zoom · Drag to pan · Esc to close";

      overlay.appendChild(viewport);
      overlay.appendChild(controls);
      overlay.appendChild(hint);
      document.body.appendChild(overlay);

      // Animate in
      requestAnimationFrame(() => overlay.classList.add("active"));

      // Apply transform
      function applyTransform() {
        svgClone.style.transform = `translate(${translateX}px, ${translateY}px) scale(${scale})`;
      }

      // Button actions
      controls.addEventListener("click", (e) => {
        const target = e.target as HTMLElement;
        const action = target.getAttribute("data-action");
        if (!action) return;

        switch (action) {
          case "zoom-in":
            scale = Math.min(scale * 1.3, 10);
            break;
          case "zoom-out":
            scale = Math.max(scale / 1.3, 0.1);
            break;
          case "fit":
            scale = 1;
            translateX = 0;
            translateY = 0;
            break;
          case "reset":
            scale = 1;
            translateX = 0;
            translateY = 0;
            break;
          case "close":
            closeViewer();
            return;
        }
        applyTransform();
      });

      // Scroll to zoom
      viewport.addEventListener("wheel", (e) => {
        e.preventDefault();
        const delta = e.deltaY > 0 ? 0.9 : 1.1;
        scale = Math.min(Math.max(scale * delta, 0.1), 10);
        applyTransform();
      });

      // Drag to pan
      viewport.addEventListener("mousedown", (e) => {
        isDragging = true;
        startX = e.clientX - translateX;
        startY = e.clientY - translateY;
      });

      viewport.addEventListener("mousemove", (e) => {
        if (!isDragging) return;
        translateX = e.clientX - startX;
        translateY = e.clientY - startY;
        applyTransform();
      });

      viewport.addEventListener("mouseup", () => {
        isDragging = false;
      });

      viewport.addEventListener("mouseleave", () => {
        isDragging = false;
      });

      // Esc to close
      function handleKeydown(e: KeyboardEvent) {
        if (e.key === "Escape") closeViewer();
      }
      document.addEventListener("keydown", handleKeydown);

      // Click overlay background to close
      overlay.addEventListener("click", (e) => {
        if (e.target === overlay) closeViewer();
      });

      function closeViewer() {
        overlay.classList.remove("active");
        document.removeEventListener("keydown", handleKeydown);
        setTimeout(() => overlay.remove(), 200);
      }
    }
  },
} satisfies Theme;
