import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleLayout(event) {
    // Get current sidebar layout from cookie
    const currentLayout = this.getCookie("sidebar_layout") || "default";
    
    // Toggle the layout
    const newLayout = currentLayout === "default" ? "two_column" : "default";
    
    // Set the cookie
    document.cookie = `sidebar_layout=${newLayout}; path=/; max-age=31536000`;
    
    // Reload the page to apply the new layout
    window.location.reload();
  }
  
  getCookie(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop().split(';').shift();
  }
} 