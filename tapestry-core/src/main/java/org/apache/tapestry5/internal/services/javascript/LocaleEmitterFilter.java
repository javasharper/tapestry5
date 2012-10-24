// Copyright 2012 The Apache Software Foundation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package org.apache.tapestry5.internal.services.javascript;

import org.apache.tapestry5.MarkupWriter;
import org.apache.tapestry5.dom.Element;
import org.apache.tapestry5.ioc.services.ThreadLocale;
import org.apache.tapestry5.services.MarkupRenderer;
import org.apache.tapestry5.services.MarkupRendererFilter;

/**
 * Responsible for the {@code data-locale} attribute written into the HTML element.
 *
 * @since 5.4
 */
public class LocaleEmitterFilter implements MarkupRendererFilter
{
    private final ThreadLocale threadLocale;

    public LocaleEmitterFilter(ThreadLocale threadLocale)
    {
        this.threadLocale = threadLocale;
    }

    @Override
    public void renderMarkup(MarkupWriter writer, MarkupRenderer renderer)
    {
        renderer.renderMarkup(writer);

        // After that's done (i.e., pretty much all rendering), touch it up a little.

        Element html = writer.getDocument().find("html");

        // If it is an HTML document, with a root HTML node, put data-locale
        // attribute inplace for the client.
        if (html != null)
        {
            html.attributes("data-locale", threadLocale.getLocale().toString());
        }
    }
}
