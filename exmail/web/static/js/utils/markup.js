'use strict';

export const generateText = (html) => {
  return (new DOMParser())
            .parseFromString(html, "text/html").body.outerText
            .split(/\n|\r|\r\n/)
            .map(s => s.trim())
            .join("\n")
}
